package domkit;

/**
	A property set by a `Rule`.
**/
class RuleStyle {
	/**
		The property.
	**/
	public var p : Property;
	/**
		The CSS value.
	**/
	public var value : CssValue;
	/**
		The handler that last parsed the value, to reuse `lastValue`.
	**/
	public var lastHandler : Component.PropertyHandler<Dynamic,Dynamic>;
	/**
		The value parsed by `lastHandler`.
	**/
	public var lastValue : Dynamic;
	/**
		The next property applied to the object (temporary list).
	**/
	public var next : RuleStyle;
	/**
		The position in the CSS source, or `null`.
	**/
	public var pos : { pmin : Int, vmin : Int, pmax : Int, file: String };
	/**
		Creates the property.
	**/
	public function new(p, value, ?pos) {
		this.p = p;
		this.value = value;
		this.pos = pos;
	}
}

/**
	A transition set by a `Rule`.
**/
class RuleTransition {
	/**
		The property.
	**/
	public var p : Property;
	/**
		The duration, in seconds.
	**/
	public var time : Float;
	/**
		The easing curve.
	**/
	public var curve : CssParser.Curve;
	/**
		The next transition applied to the object (temporary list).
	**/
	public var next : RuleTransition;
	/**
		Creates the transition.
	**/
	public function new(p, time, curve) {
		this.p = p;
		this.time = time;
		this.curve = curve;
	}
}

/**
	A CSS rule for one selector, with its priority.
**/
class Rule {
	/**
		The index of the rule, to keep the declaration order among rules of equal priority.
	**/
	public var id : Int;
	/**
		The priority, from the specificity of the selector (ids, then classes and pseudo classes, then components) and `!important`.
	**/
	public var priority : Int;
	/**
		The selector.
	**/
	public var cl : CssParser.CssClass;
	/**
		The properties.
	**/
	public var style : Array<RuleStyle>;
	/**
		The transitions, or `null`.
	**/
	public var transitions : Array<RuleTransition>;
	/**
		Creates an empty rule.
	**/
	public function new() {
	}
}

/**
	A running transition of a property of an object.
**/
class CssTransition {
	/**
		The object.
	**/
	public var properties : Properties<Dynamic>;
	/**
		The transition.
	**/
	public var trans : RuleTransition;
	/**
		The handler applying the values.
	**/
	public var handler : Component.PropertyHandler<Dynamic,Dynamic>;
	/**
		The start value.
	**/
	public var vstart : Dynamic;
	/**
		The target value.
	**/
	public var vtarget : Dynamic;
	/**
		The progress, from `0` to `1`.
	**/
	public var progress : Float;
	/**
		Tells if the value is not a number: it changes at the end of the transition (unless the handler interpolates it).
	**/
	public var discrete : Bool;
	/**
		Creates the transition.
	**/
	public function new() {
	}
}

#if hl
/**
	Bytes used for the component bit sets of the style cache: `hl.Bytes` on HashLink, `haxe.io.Bytes` elsewhere.
**/
@:forward(fill)
abstract FastBytes(hl.Bytes) to hl.Bytes {
	/**
		Returns the byte at the index.
	**/
	public inline function get(index) return this.getUI8(index);
	/**
		Sets the byte at the index.
	**/
	public inline function set(index,value) this.setUI8(index, value);
	/**
		Returns a copy of `len` bytes from the index.
	**/
	public inline function sub(index,len) : FastBytes return cast this.sub(index, len);
	/**
		Returns the bytes of an `haxe.io.Bytes`.
	**/
	@:from public static inline function fromBytes(bytes:haxe.io.Bytes) : FastBytes {
		return cast @:privateAccess bytes.b;
	}
}

/**
	An entry of a `BytesMap`.
**/
class BytesCell<T> {
	/**
		The key.
	**/
	public var bytes : hl.Bytes;
	/**
		The value.
	**/
	public var value : T;
	/**
		The next entry with the same hash.
	**/
	public var next : BytesCell<T>;
	/**
		Creates the entry.
	**/
	public function new(bytes,value,next) {
		this.bytes = bytes;
		this.value = value;
		this.next = next;
	}
}

/**
	A map with bytes keys, used by the style cache on HashLink.
**/
abstract BytesMap<T>(Map<Int,BytesCell<T>>) {

	static var BUF = new hl.Bytes(4);

	/**
		Creates an empty map.
	**/
	public function new() {
		this = [];
	}

	inline function makeHash( bytes : hl.Bytes, len : Int ) {
		var buf = BUF;
		buf.fill(0, 4, 0);
		hl.Format.digest(buf,bytes,len,3);
		return buf.getI32(0);
	}

	/**
		Returns the value of the first `len` bytes, or `null`.
	**/
	public inline function get( bytes : hl.Bytes, len : Int ) {
		var h = makeHash(bytes, len);
		var c = this.get(h);
		var value = null;
		while( c != null ) {
			if( c.bytes.compare(0, bytes, 0, len) == 0 ) {
				value = c.value;
				break;
			}
			c = c.next;
		}
		return value;
	}

	/**
		Sets the value of the first `len` bytes.
	**/
	public inline function set( bytes : hl.Bytes, len : Int, value ) {
		var h = makeHash(bytes, len);
		var c = new BytesCell(bytes.sub(0,len), value, this.get(h));
		this.set(h, c);
	}

}
#else

/**
	Bytes used for the component bit sets of the style cache: `hl.Bytes` on HashLink, `haxe.io.Bytes` elsewhere.
**/
typedef FastBytes = haxe.io.Bytes;

#end

/**
	The rules of a `CssStyle`, sorted by priority, and the cache of the rules matching a set of components.
**/
class CssData {

	/**
		The number of components with an id.
	**/
	public static var CID = 0;
	/**
		The components used by the rules, by id.
	**/
	public static var COMPONENTS = [];

	/**
		The rules, sorted by decreasing priority after `init`.
	**/
	public var rules : Array<Rule>;
	/**
		The size of the component bit sets.
	**/
	public var bytesSize : Int = 0;
	/**
		Tells if rules were added since the last `init`.
	**/
	public var needsInit = false;

	var rulesByComp : #if hl BytesMap<Array<Rule>> #else Map<String,Array<Rule>> #end;

	/**
		Creates empty data.
	**/
	public function new() {
		rules = [];
	}

	function sortByPriority(r1:Rule, r2:Rule) {
		if (r2.priority != r1.priority)
			return r2.priority > r1.priority ? 1 : -1;
		return r2.id - r1.id;
	}

	/**
		Gives an id to the component, if not done yet.
	**/
	public static function registerComponent(c:Component<Dynamic,Dynamic>) {
		if( c != null && c.id < 0 ) {
			COMPONENTS.push(c);
			c.id = CID++;
		}
	}

	/**
		Sorts the rules and registers their components, if rules were added.
	**/
	public function init() {
		if( needsInit ) {
			needsInit = false;
			rules.sort(sortByPriority);
			// attribute component ids
			var prev = COMPONENTS.length;
			for( r in rules ) {
				var cl = r.cl;
				while( cl != null ) {
					if( cl.component != null )
						registerComponent(cl.component);
					cl = cl.parent;
				}
			}
			// add all children
			while( prev < COMPONENTS.length ) {
				var c = COMPONENTS[prev++];
				for( c2 in @:privateAccess Component.COMPONENTS ) {
					if( c2.parent == c )
						registerComponent(c2);
				}
			}
			bytesSize = -1;
		}
		var reqSize = (CssData.CID >> 3) + 1;
		if( reqSize > bytesSize ) {
			bytesSize = reqSize;
			rulesByComp = #if hl new BytesMap() #else new Map() #end;
		}
	}

	/**
		Returns the rules cached for the set of components, or `null`.
	**/
	public inline function getCache( bits : FastBytes ) : Array<Rule> {
		return rulesByComp.get(#if hl bits, bytesSize #else bits.toHex() #end);
	}

	/**
		Caches the rules of the set of components.
	**/
	public inline function setCache( bits : FastBytes, value : Array<Rule> ) {
		rulesByComp.set(#if hl bits, bytesSize #else bits.toHex() #end, value);
	}

	/**
		Adds the rules of a style sheet.
	**/
	public function add( sheet : CssParser.CssSheet ) {
		for( r in sheet ) {
			for( cl in r.classes ) {
				var nids = 0, nothers = 0, nnodes = 0, notimp = false;
				var c = cl;
				while( c != null ) {
					if( c.id.isDefined() ) nids++;
					if( c.component != null ) {
						nnodes += 32;
						var k = c.component.parent;
						while( k != null ) {
							nnodes++;
							k = k.parent;
						}
					}
					if( c.pseudoClasses != None ) {
						var i = c.pseudoClasses.toInt();
						while( i != 0 ) {
							if( i & 1 != 0 ) nothers++;
							i >>>= 1;
						}
						if( c.pseudoClasses.has(NotImportant) )
							notimp = true;
					}
					if( c.className != null ) nothers++;
					c = c.parent;
				}
				var priority = (nids << 24) | (nothers << 17) | nnodes;
				var important = null;
				var rule = new Rule();
				rule.id = rules.length;
				rule.cl = cl;
				rule.style = [];
				for( s in r.style )
					switch( s.value ) {
					case VLabel("important", val):
						if( important == null ) important = [];
						important.push(new RuleStyle(s.p, val, s));
					default:
						rule.style.push(new RuleStyle(s.p, s.value, s));
					}
				rule.priority = priority;
				if( notimp ) rule.priority -= 1 << 30;
				if( r.transitions != null ) {
					rule.transitions = [];
					for( t in r.transitions )
						rule.transitions.push(new RuleTransition(t.p, t.time, t.curve));
				}
				if( rule.style.length > 0 || rule.transitions != null )
					rules.push(rule);
				if( important != null ) {
					var tr = rule.transitions;
					rule.transitions = null;
					var rule = new Rule();
					rule.id = rules.length;
					rule.cl = cl;
					rule.style = important;
					rule.priority = priority + (1 << 30);
					rule.transitions = tr;
					rules.push(rule);
				}
			}
		}
		needsInit = true;
	}

	/**
		Removes all the rules.
	**/
	public function clear() {
		rules.resize(0);
		needsInit = true;
	}
}

/**
	A style: CSS rules applied to objects with `Properties.applyStyle`, and the running transitions, updated with `updateTime`.
**/
@:access(domkit.Properties)
class CssStyle {

	static var TAG = 0;

	/**
		The rules.
	**/
	public var data : CssData;
	/**
		Caches the rules matching each set of components of an object and its parents, to test fewer rules.
	**/
	public var useSmartCache = true;
	var currentTransitions : Array<CssTransition> = [];
	var componentsBits : FastBytes;
	var compSize : Int = 0;
	var inApply = false;

	/**
		Creates an empty style.
	**/
	public function new() {
		data = new CssData();
	}

	function onInvalidProperty( e : Properties<Dynamic>, s : RuleStyle, msg : String ) {
	}

	function addTransition( e : Properties<Dynamic>, trans : RuleTransition, h : Component.PropertyHandler<Dynamic,Dynamic>, vtarget : Dynamic ) {
		if( e.transitionValues == null ) e.transitionValues = new Map();
		var vstart : Dynamic = e.transitionValues.get(trans.p.id);
		if( vstart == null ) vstart = h.defaultValue;
		if( vtarget == null ) vtarget = h.defaultValue;

		for( c in currentTransitions ) {
			if( c.properties == e && c.trans.p == trans.p ) {
				// return to same value ?
				if( c.vstart == vtarget ) {
					c.vstart = c.vtarget;
					c.progress = 1 - c.progress;
				} else {
					c.vstart = vstart;
					c.progress = 0; // reset progress (unknown "distance")
				}
				c.vtarget = vtarget;
				return;
			}
		}
		var t = new CssTransition();
		t.properties = e;
		t.handler = h;
		t.trans = trans;
		t.vstart = vstart;
		t.vtarget = vtarget;
		t.discrete = !Std.isOfType(vtarget == null ? vstart : vtarget, Float);
		t.progress = 0;
		e.transitionCount++;
		currentTransitions.push(t);
	}

	inline function setCompBit( id : Int ) {
		if( id < 0 )
			return -1;
		var pos = id >> 3;
		var v = componentsBits.get(pos);
		var msk = 1 << (id & 7);
		if( (v & msk) == 0 ) {
			componentsBits.set(pos,v | msk);
			return v;
		}
		return -1;
	}

	function getCurrentRules() {
		var rules = data.getCache(componentsBits);
		if( rules == null ) {
			// complete bits with superclasses
			var prev = componentsBits;
			var change = false;
			for( c in CssData.COMPONENTS ) {
				if( componentsBits.get(c.id>>3)&(1<<(c.id&7)) != 0 ) {
					var p = c.parent;
					while( p != null ) {
						var v = setCompBit(p.id);
						if( v >= 0 && !change ) {
							change = true;
							prev = componentsBits.sub(0, compSize);
							prev.set(p.id>>3, v);
						}
						p = p.parent;
					}
				}
			}
			if( change )
				rules = data.getCache(componentsBits);
			if( rules == null ) {
				rules = [];
				for( r in data.rules ) {
					var cl = r.cl;
					var ignore = false;
					while( cl != null ) {
						if( cl.component != null ) {
							var id = cl.component.id;
							if( componentsBits.get(id>>3)&(1<<(id&7)) == 0 ) {
								ignore = true;
								break;
							}
						}
						cl = cl.parent;
					}
					if( ignore ) continue;
					rules.push(r);
				}
				if( change )
					data.setCache(componentsBits,rules);
			}
			componentsBits = prev;
			data.setCache(componentsBits,rules);
		}
		return rules;
	}

	function syncDirty( e : Properties<Dynamic> ) {
		var dirty = e.dirty;
		while (!dirty.empty()) {
			var p = dirty.head;
			if(p.needStyleRefresh)
				applyStyle(p, false);
			else
				dirty.remove(p);
		}
	}

	function applyStyle( e : Properties<Dynamic>, force : Bool ) {
		data.init();
		if( !useSmartCache ) {
			applyStyleRec(e, force, data.rules);
			return;
		}
		if( compSize < data.bytesSize ) {
			compSize = data.bytesSize;
			componentsBits = haxe.io.Bytes.alloc(compSize);
		}
		var prevApply = inApply;
		var prevBits = null;
		if( prevApply ) {
			prevBits = componentsBits;
			componentsBits = haxe.io.Bytes.alloc(compSize);
		} else
			componentsBits.fill(0,compSize,0);
		var cur = e.parent;
		while( cur != null ) {
			setCompBit(cur.component.id);
			cur = cur.parent;
		}
		this.inApply = true;
		applyStyleRec(e, force, null);
		this.inApply = prevApply;
		if( prevApply )
			componentsBits = prevBits;
	}

	function applyStyleRec( e : Properties<Dynamic>, force : Bool, rules : Array<Rule> ) {
		var prev = -1;
		if( useSmartCache ) {
			prev = setCompBit(e.component.id);
			if( prev >= 0 ) rules = null;
		}

		if( e.needStyleRefresh || force ) {
			e.dirty.remove(e);  // Remove first so that cascading dirty still get added
			var firstInit = e.firstInit;
			e.firstInit = false;
			e.needStyleRefresh = false;
			var head = null, transHead : RuleTransition = null;
			var tag = ++TAG;
			var prevTransCount = e.transitionCount;
			for( p in e.style )
				p.p.tag = tag;

			inline function addTransition(p:Property,h,target:Dynamic) {
				var t = transHead;
				while( true ) {
					if( t.p == p ) {
						this.addTransition(e, t, h, target);
						break;
					}
					t = t.next;
				}
			}

			if( rules == null )
				rules = getCurrentRules();

			for( r in rules ) {
				if( !ruleMatch(r.cl,e) ) continue;
				var i = r.style.length - 1;
				while( i >= 0 ) {
					var p = r.style[i--];
					if( p.p.tag != tag ) {
						p.p.tag = tag;
						p.next = head;
						head = p;
					}
				}
				if( r.transitions != null ) {
					for( t in r.transitions ) {
						if( t.p.transTag != tag ) {
							t.p.transTag = tag;
							t.next = transHead;
							transHead = t;
						}
					}
				}
			}

			/*
			// debug check that the filtering doesn't forget any rule
			for( r in data.rules ) {
				if( ruleMatch(r.cl,e) && rules.indexOf(r) < 0 ) {
					var comps = [];
					for( id in 0...CssData.CID ) {
						if( componentsBits.get(id>>3)&(1<<(id&7)) != 0 )
							comps.push(CssData.COMPONENTS[id]);
					}
					throw "assert";
				}
			}*/

			// reset to default previously set properties that are no longer used
			var changed = false;
			var ntag = ++TAG;
			var i = e.currentSet.length - 1;
			while( i >= 0 ) {
				var p = e.currentSet[i--];
				if( p.tag == tag )
					p.tag = ntag;
				else {
					changed = true;
					e.currentSet.remove(p);
					if( e.currentValues != null ) e.currentValues.splice(i+1,1);
					if( e.currentRuleStyles != null ) e.currentRuleStyles.splice(i+1,1);
					var h = e.component.getHandler(p);
					if( p.transTag == tag ) {
						p.transTag = ntag;
						addTransition(p, h, null);
						continue;
					}
					h.apply(e.obj,h.defaultValue);
					if( p.hasTransition ) e.transitionValues.set(p.id, null);
				}
			}
			// apply new properties
			var p = head;
			while( p != null ) {
				var pr = p.p;
				var h = e.component.getHandler(pr);
				var next = p.next;
				p.next = null;
				if( h == null ) {
					onInvalidProperty(e, p, "Unsupported property");
					p = next;
					continue;
				}

				if( p.lastHandler != h ) {
					try {
						var value = h.parser(p.value);
						p.lastHandler = h;
						p.lastValue = value;
					} catch( err : Property.InvalidProperty ) {
						// invalid property
						onInvalidProperty(e, p, err.message);
						p = next;
						continue;
					}
				}

				if( (pr.transTag == tag || pr.transTag == ntag) && !firstInit ) {
					pr.transTag = ntag;
					addTransition(pr, h, p.lastValue);
				} else {
					h.apply(e.obj, p.lastValue);
					changed = true;

					if( pr.hasTransition ) {
						if( e.transitionValues == null ) e.transitionValues = new Map();
						e.transitionValues.set(pr.id, p.lastValue);
						pr.transTag = tag - 1;
					}
				}

				if( pr.tag != ntag ) {
					if( Properties.KEEP_VALUES ) {
						e.initCurrentValues();
						e.currentValues.push(p.value);
						e.currentRuleStyles.push(p);
					}
					e.currentSet.push(pr);
					pr.tag = ntag;
				} else {
					if( Properties.KEEP_VALUES ) {
						e.initCurrentValues();
						var idx = e.currentSet.indexOf(pr);
						e.currentValues[idx] = p.value;
						e.currentRuleStyles[idx] = p;
					}
				}
				p = next;
			}

			// cancel transitions that are no longer valid
			if( prevTransCount > 0 ) {
				var i = 0;
				var max = currentTransitions.length;
				while( i < max ) {
					var c = currentTransitions[i++];
					if( c.properties == e && c.trans.p.transTag != ntag ) {
						currentTransitions.remove(c);
						e.transitionCount--;
						i--;
						max--;
						if( c.trans.p.tag != ntag )
							e.transitionValues.set(c.trans.p.id, c.handler.defaultValue);
					}
				}
			}

			// transitions set on unset values : define default value
			var t = transHead;
			while( t != null ) {
				if( t.p.transTag == tag && e.transitionValues != null )
					e.transitionValues.set(t.p.id, null);
				t = t.next;
			}

			// reapply style properties
			if( changed ) {
				for( p in e.style ) {
					var h = e.component.getHandler(p.p);
					if( h != null ) h.apply(e.obj, p.value);
				}
				// if our style change triggered a class change
				// we will rebuild it but let's not trigger transition
				if( firstInit && e.needStyleRefresh ) e.firstInit = true;
			}
			// parent style has changed, we need to sync children
			force = true;
		}
		var obj : Model<Dynamic> = e.obj;
		for( c in @:privateAccess obj.getChildren() ) {
			var c : Model<Dynamic> = c;
			if( c.dom == null )
				continue;
			applyStyleRec(c.dom, force, rules);
		}

		if( prev >= 0 )
			componentsBits.set(e.component.id >> 3, prev);
	}

	/**
		Updates the running transitions, `dt` being the elapsed time in seconds.
	**/
	public function updateTime( dt : Float ) {
		var i = 0;
		var max = currentTransitions.length;
		while( i < max ) {
			var c = currentTransitions[i++];
			c.progress += dt / c.trans.time;
			var current : Dynamic = null;
			if( c.progress > 1 ) {
				c.progress = 1;
				current = c.vtarget;
				c.properties.transitionCount--;
				currentTransitions.remove(c);
				i--;
				max--;
			} else if( c.handler.transition != null )
				current = c.handler.transition(c.vstart, c.vtarget, c.trans.curve.interpolate(c.progress));
			else if(c.discrete)
				current = c.progress < 1 ? c.vstart : c.vtarget;
			else {
				var vstart : Float = c.vstart;
				var vtarget : Float = c.vtarget;
				current = (vtarget - vstart) * c.trans.curve.interpolate(c.progress) + vstart;
			}
			c.handler.apply(c.properties.obj, current);
			c.properties.transitionValues.set(c.trans.p.id, current);
		}
	}

	/**
		Adds the rules of a style sheet.
	**/
	public function add( sheet : CssParser.CssSheet ) {
		data.add(sheet);
	}
	/**
		Removes all the rules.
	**/
	public function clear() {
		data.clear();
	}

	/**
		Tells if the selector matches the object.
	**/
	public static function ruleMatch( c : CssParser.CssClass, e : Properties<Dynamic> ) {
		if( c.id.isDefined() && c.id != e.id )
			return false;
		if( c.pseudoClasses != None ) {
			if( c.pseudoClasses.has(Hover) && !e.hover )
				return false;
			if( c.pseudoClasses.has(Active) && !e.active )
				return false;
			if( c.pseudoClasses.has(Disabled) && !e.disabled )
				return false;
			if( c.pseudoClasses.has(Focus) && !e.focus )
				return false;
			if( c.pseudoClasses.has(NeedChildren) ) {
				var parent = e.parent;
				if( parent == null )
					return false;
				var children = @:privateAccess parent.obj.getChildren();
				var index = @:privateAccess parent.obj.getChildRefPosition(true);
				if( c.pseudoClasses.has(FirstChild) && children[index] != e.obj )
					return false;
				if( c.pseudoClasses.has(LastChild) && children[@:privateAccess parent.obj.getChildRefPosition(false)] != e.obj )
					return false;
				if( c.pseudoClasses.has(Odd) && (children.indexOf(e.obj) - index) & 1 == 0 )
					return false;
				if( c.pseudoClasses.has(Even) && (children.indexOf(e.obj) - index) & 1 != 0 )
					return false;
			}
		}
		if( c.component != null && !e.component.isOfType(c.component) )
			return false;
		if( c.className != null ) {
			if( e.classes == null )
				return false;
			var found = false;
			var cl : domkit.Identifier = c.className;
			for( cc in e.classes )
				if( cc == cl ) {
					found = true;
					break;
				}
			if( !found )
				return false;
			if( c.extraClasses != null ) {
				for( cname in c.extraClasses ) {
					var found = false;
					for( cc in e.classes )
						if( cc == cname ) {
							found = true;
							break;
						}
					if( !found )
						return false;
				}
			}
		}
		if( c.parent != null ) {
			var p = e.parent;
			switch( c.relation ) {
			case None:
				while( p != null ) {
					if( ruleMatch(c.parent, p) )
						break;
					p = p.parent;
				}
				if( p == null )
					return false;
			case ImmediateChildren:
				return p != null && ruleMatch(c.parent, p);
			case SubRule:
				throw "assert";
			}
		}
		return true;
	}

}
