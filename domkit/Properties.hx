package domkit;

/**
	The result of `Properties.setAttribute`.
**/
enum SetAttributeResult {
	/**
		The value was applied.
	**/
	Ok;
	/**
		The property is unknown.
	**/
	Unknown;
	/**
		The component doesn't support the property.
	**/
	Unsupported;
	/**
		The value is invalid for the property.
	**/
	InvalidValue( ?msg : String );
}

@:access(domkit.Properties)
private class DirtyList<T:Model<T>> {
	public var head : Properties<T>;
	public var tail : Properties<T>;
	public var addCount = 0;

	public function new() {}

	public function empty() {
		return head == null;
	}

	public function add(p : Properties<T>) {
		if (p.isDirty()) return;
		addCount++;

		// Skip if immediate parent is already in list
		var parent = p.parent;
		if (parent != null && parent.isDirty())
			return;

		if (tail == null) {
			p.dirtyPrev = null;
			p.dirtyNext = null;
			head = tail = p;
			return;
		}

		// Insert-sort
		var cur = tail;
		while (cur != null && cur.depth > p.depth)
			cur = cur.dirtyPrev;

		if (cur == null) {
			// Insert at head
			p.dirtyPrev = null;
			p.dirtyNext = head;
			head.dirtyPrev = p;
			head = p;
		} else {
			// Insert after cur
			p.dirtyPrev = cur;
			p.dirtyNext = cur.dirtyNext;
			if (cur.dirtyNext != null)
				cur.dirtyNext.dirtyPrev = p;
			else
				tail = p;
			cur.dirtyNext = p;
		}
	}

	public function remove(p : Properties<T>) {
		if(!p.isDirty())
			return;
		if (p.dirtyPrev != null) p.dirtyPrev.dirtyNext = p.dirtyNext;
		if (p.dirtyNext != null) p.dirtyNext.dirtyPrev = p.dirtyPrev;
		if (p == head) head = p.dirtyNext;
		if (p == tail) tail = p.dirtyPrev;
		p.dirtyPrev = null;
		p.dirtyNext = null;
	}
}

/**
	The DomKit state of an object (its `dom` field): component, id, classes, pseudo class states (`hover`, `active`...) and the CSS values set on it. Changing them marks the object to be styled again by the next `applyStyle`.
**/
class Properties<T:Model<T>> {

	/**
		The id of the object (`#id` in CSS), set with `setId`.
	**/
	public var id(default,null) : Identifier;
	/**
		The object.
	**/
	public var obj(default,null) : Model<T>;
	/**
		The component of the object.
	**/
	public var component(default,null) : Component<T,Dynamic>;
	/**
		Matches the `:hover` pseudo class.
	**/
	public var hover(default,set) : Bool = false;
	/**
		Matches the `:active` pseudo class.
	**/
	public var active(default,set) : Bool = false;
	/**
		Matches the `:disabled` pseudo class.
	**/
	public var disabled(default,set) : Bool = false;
	/**
		Matches the `:focus` pseudo class.
	**/
	public var focus(default,set) : Bool = false;
	/**
		The properties of the parent object, or `null`.
	**/
	public var parent(get,never) : Properties<T>;
	/**
		The object to which the children declared in the markup are added (the object itself by default).
	**/
	public var contentRoot(default,null) : Model<T>;

	var classes : Array<Identifier>;
	var style : Array<{ p : Property, value : Any }> = [];
	var currentSet : Array<Property> = [];
	var currentValues : Array<CssValue>; // only for inspector
	var currentRuleStyles : Array<CssStyle.RuleStyle>; // only for inspector
	var transitionValues : Map<Int,Dynamic>;
	var needStyleRefresh : Bool = true;
	var firstInit : Bool = true;
	var transitionCount : Int = 0;
	var dirty : DirtyList<T>;
	var dirtyPrev : Properties<T>;
	var dirtyNext : Properties<T>;
	var depth : Int = 0;

	static var KEEP_VALUES = false;

	/**
		Creates the properties of the object.
	**/
	public function new(obj,component) {
		this.obj = obj;
		this.component = component;
		this.contentRoot = obj;
		onParentChanged();
		needRefresh();
	}

	inline function isDirty() {
		return dirtyPrev != null || dirtyNext != null || dirty.head == this;
	}

	inline function needRefresh() {
		needStyleRefresh = true;
		dirty.add(this);
		checkLoop();
	}

	static function checkLoop() {
		if( APPLY_LOOPS > 100 ) throw "Infinite loop in apply style";
	}

	static var EMPTY_CLASSES = [];
	/**
		Returns the classes of the object.
	**/
	public function getClasses() : Iterable<Identifier> {
		return classes == null ? EMPTY_CLASSES : classes;
	}

	/**
		Tells if the object has the class.
	**/
	public function hasClass( name : String ) {
		if( classes == null )
			return false;
		return classes.indexOf(new Identifier(name)) >= 0;
	}

	/**
		Must be called when the object is added to or removed from a parent, to style it again.
	**/
	public function onParentChanged( ?prev : Properties<T> ) {
		var p = parent;
		if( dirty != null )
			dirty.remove(this);
		if( p == null ) {
			dirty = new DirtyList<T>();
			depth = 0;
			if( prev != null )
				prev.needRefresh(); // can change :first-child etc.
		} else {
			dirty = p.dirty;
			depth = p.depth + 1;
			needRefresh();
		}
		for( c in @:privateAccess obj.getChildren() )
			if( c.dom != null )
				c.dom.onParentChanged();
	}

	inline function get_parent() : Properties<T> {
		var p = obj.parent;
		return p == null ? null : cast p.dom;
	}

	/**
		Adds a class.
	**/
	public function addClass( c : String ) {
		if( c == null )
			return;
		if( classes == null )
			classes = [];
		var c = new Identifier(c);
		if( classes.indexOf(c) < 0 ) {
			classes.push(c);
			needRefresh();
		}
	}

	static var APPLY_LOOPS = 0;

	/**
		Applies the style to the objects that need it, from this object's tree.
	**/
	public function applyStyle( style : CssStyle ) @:privateAccess {
		var prev = APPLY_LOOPS;
		var wasDirty = false;
		APPLY_LOOPS = 0;
		var cnt = 0;
		do {
			// Keep applying until no new dirty elements are added
			cnt = dirty.addCount;
			style.applyStyle(this, true);
			APPLY_LOOPS++;
		} while( dirty.addCount > cnt );
		APPLY_LOOPS = prev;
		dirty.addCount = 0;
	}

	/**
		Removes a class.
	**/
	public function removeClass( c : String ) {
		if( classes == null || c == null )
			return;
		var c = new Identifier(c);
		if( classes.remove(c) ) {
			needRefresh();
			if( classes.length == 0 ) classes = null;
		}
	}

	/**
		Adds the class if `b` is set, removes it if `b` is `false`, or toggles it if `b` is `null`.
	**/
	public function toggleClass( c : String, ?b : Bool ) {
		if( c == null )
			return;
		if( b == null ) {
			var c = new Identifier(c);
			if( classes == null )
				classes = [c];
			else if( classes.remove(c) ) {
				if( classes.length == 0 ) classes = null;
			} else
				classes.push(c);
			needRefresh();
		} else if( b )
			addClass(c);
		else
			removeClass(c);
	}

	function set_hover(b) {
		if( hover == b ) return b;
		needRefresh();
		return hover = b;
	}

	function set_active(b) {
		if( active == b ) return b;
		needRefresh();
		return active = b;
	}

	function set_disabled(b) {
		if( disabled == b ) return b;
		needRefresh();
		return disabled = b;
	}

	function set_focus(b) {
		if( focus == b ) return b;
		needRefresh();
		return focus = b;
	}

	function initStyle( p : String, value : Dynamic ) {
		style.push({ p : Property.get(p), value : value });
		needRefresh();
	}

	/**
		Sets the attributes from their CSS strings (see `setAttribute`). Invalid ones are printed on `sys` targets.
	**/
	public function initAttributes( attr : haxe.DynamicAccess<String> ) {
		var parser = new CssParser();
		for( a in attr.keys() ) {
			var ret;
			var p = Property.get(a,false);
			if( p == null )
				ret = Unknown;
			else {
				var h = component.getHandler(p);
				if( h == null && p != pclass && p != pid )
					ret = Unsupported;
				else
					ret = setAttribute(a, parser.parseValue(attr.get(a)));
			}
			#if sys
			if( ret != Ok ) {
				if( ret.match(InvalidValue(null)) ) ret = InvalidValue(attr.get(a));
				Sys.println(component.name+"."+a+"> "+ret);
			}
			#end
		}
	}

	/**
		Replaces the classes, from a string (`"a b"`) or from an object whose fields set to `true` are the classes (`_` becoming `-`).
	**/
	public function setClasses( ?classStr : String, ?classObj : Dynamic<Bool> ) {
		var cl;
		if( classStr != null )
			cl = classStr.split(" ");
		else if( classObj != null ) {
			cl = [];
			for( f in Reflect.fields(classObj) )
				if( Reflect.field(classObj,f) )
					cl.push(f.split("_").join("-"));
		} else
			cl = [];
		var prevClasses = classes;
		classes = [];
		for( c in cl ) {
			var c = StringTools.trim(c);
			if( c.length == 0 ) continue;
			classes.push(new Identifier(c));
		}
		if( classes.length == 0 )
			classes = null;
		if( !sameClasses(classes,prevClasses) )
			needRefresh();
	}
	/**
		Adds classes, from a string (`"a b"`) or from an object whose fields set to `true` are the classes (`_` becoming `-`).
	**/
	public function appendClasses( ?classStr : String, ?classObj : Dynamic<Bool> ) {
		var cl;
		if( classStr != null )
			cl = classStr.split(" ");
		else if( classObj != null ) {
			cl = [];
			for( f in Reflect.fields(classObj) )
				if( Reflect.field(classObj,f) )
					cl.push(f.split("_").join("-"));
		} else
			cl = [];

		var prevClasses = classes == null ? null : classes.copy();
		for( c in cl ) {
			var c = StringTools.trim(c);
			if( c.length == 0 ) continue;
			var c = new Identifier(c);
			if( classes == null )
				classes = [c];
			else if( classes.indexOf(c) < 0 ) {
				classes.push(c);
			}
		}
		if( classes != null && classes.length == 0 )
			classes = null;
		if( !sameClasses(classes,prevClasses) )
			needRefresh();
	}

	static inline function sameClasses( cl1 : Array<Identifier>, cl2 : Array<Identifier> ) {
		if( (cl1 == null ? 0 : cl1.length) != (cl2 == null ? 0 : cl2.length) )
			return false;
		if( cl1 == null )
			return true;
		var ok = true;
		for( i in 0...cl1.length )
			if( cl1[i] != cl2[i] ) {
				ok = false;
				break;
			}
		return ok;
	}

	/**
		Removes the class starting with `kind-` and adds the class `kind-value` instead (none if `value` is `null`).
	**/
	public function setClassKind( kind : String, value : String ) {
		kind += "-";
		var full = value == null ? null : new Identifier(kind + value);
		if( classes == null ) classes = [];
		for( c in classes )
			if( StringTools.startsWith(c.toString(),kind) ) {
				if( c == full ) return;
				classes.remove(c);
				break;
			}
		if( full != null )
			classes.push(full);
		else if( classes.length == 0 )
			classes = null;
		needRefresh();
	}

	/**
		Sets the id of the object, or `null`.
	**/
	public function setId( id : String ) {
		var id = id == null ? null : new Identifier(id);
		if( this.id == id ) return;
		this.id = id;
		updateComponentId(this);
		needRefresh();
	}

	/**
		Sets a property of the object, as an inline style (it has priority over the CSS rules), and applies it. `id` and `class` set the id and add classes.
	**/
	public function setAttribute( p : String, value : CssValue ) : SetAttributeResult {
		var p = Property.get(p,false);
		if( p == null )
			return Unknown;
		if( p.id == pid.id ) {
			switch( value ) {
			case VIdent(i): setId(i);
			default: return InvalidValue();
			}
			return Ok;
		}
		if( p.id == pclass.id ) {
			// keep previous classes !! (declaring component <xxx class="foo"/> should not erase previous classes)
			if( classes == null )
				classes = [];
			switch( value ) {
			case VIdent(i): classes.push(new Identifier(i));
			case VGroup(vl): for( v in vl ) switch( v ) { case VIdent(i): classes.push(new Identifier(i)); default: return InvalidValue(); }
			default: return InvalidValue();
			}
			needRefresh();
			return Ok;
		}
		var handler = component.getHandler(p);
		if( handler == null )
			return Unsupported;
		var v : Dynamic;
		try {
			v = handler.parser(value);
		} catch( e : Property.InvalidProperty ) {
			return InvalidValue(e.message);
		}
		var found = false;
		for( s in style )
			if( s.p == p ) {
				s.value = v;
				style.remove(s);
				style.push(s);
				found = true;
				break;
			}
		if( !found ) {
			style.push({ p : p , value : v });
			for( s in currentSet )
				if( s == p ) {
					found = true;
					if( KEEP_VALUES ) {
						initCurrentValues();
						var idx = currentSet.indexOf(p);
						currentValues[idx] = value;
						currentRuleStyles[idx] = null;
					}
					break;
				}
			if( !found ) {
				if( KEEP_VALUES ) {
					initCurrentValues();
					currentValues.push(value);
					currentRuleStyles.push(null);
				}
				currentSet.push(p);
			}
		}
		if( p.hasTransition ) {
			if( transitionValues == null ) transitionValues = new Map();
			transitionValues.set(p.id, v);
		}
		handler.apply(obj,v);
		return Ok;
	}

	function initCurrentValues() {
		if( currentValues == null )
			currentValues = [for( s in currentSet ) null];
		if( currentRuleStyles == null )
			currentRuleStyles = [for( s in currentSet ) null];
	}

	static var pclass = Property.get("class");
	static var pid = Property.get("id");

	static dynamic function updateComponentId( p : Properties<Dynamic> ) {
	}

	/**
		Creates the properties of an existing object for the component of the given name, with optional attributes.
	**/
	public static function create<BaseT:Model<BaseT>,T:BaseT>( comp : String, value : T, ?attributes : haxe.DynamicAccess<String> ) {
		if( value == null ) throw "Component value is not set";
		var c = Component.get(comp);
		var p = new Properties<BaseT>(value, cast c);
		if( attributes != null )
			p.initAttributes(attributes);
		return p;
	}

	static function createNew<T:Model<T>>( comp : String, parent : Properties<T>, args : Array<Dynamic>, ?attributes : haxe.DynamicAccess<String> ) : Properties<T> {
		var c = Component.get(comp);
		var value : T = c.make(args, parent == null ? null : parent.contentRoot);
		var p : Properties<T> = cast value.dom;
		if( p == null )
			value.dom = cast (p = new Properties<T>(value, cast c));
		if( attributes != null )
			p.initAttributes(attributes);
		return p;
	}

}
