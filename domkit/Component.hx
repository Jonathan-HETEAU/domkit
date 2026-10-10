package domkit;
import domkit.Property;

/**
	How a component handles a CSS property: parses its value, applies it to the objects of type `O`, and interpolates it for the transitions.
**/
class PropertyHandler<O,P> {

	/**
		Converts the CSS value to the property value. Throws `Property.InvalidProperty` if invalid.
	**/
	public var parser(default,null) : CssValue -> P;
	#if !macro
	/**
		The value applied when no CSS rule sets the property.
	**/
	public var defaultValue(default,null) : P;
	/**
		Applies the value to an object.
	**/
	public var apply(default,null) : O -> P -> Void;
	/**
		Interpolates between two values, or `null` (floats are interpolated, other values change at the end of the transition).
	**/
	public var transition(default,null) : P -> P -> Float -> P;
	#end

	#if macro
	public var defaultValue : haxe.macro.Expr;
	public var type : haxe.macro.Expr.ComplexType;
	public var position : haxe.macro.Expr.Position;
	public var parserExpr : haxe.macro.Expr;
	public var transitionExpr : haxe.macro.Expr;
	public var fieldName : String;
	#end

	/**
		Creates the handler.
	**/
	public function new(parser,def,applyType) {
		this.parser = parser;
		this.defaultValue = def;
		#if macro
		this.type = applyType;
		#else
		this.apply = applyType;
		#end
	}
}

/**
	Declares the component of another class `T`: a class implementing `ComponentDecl<T>` (with `domkit.Object`) defines the properties of `T`, for classes that can't be modified.
**/
interface ComponentDecl<T> {
}

/**
	A component: the name used in the markup and in CSS (`button`, `flow`...), how to create its objects of type `T`, and how it handles the CSS properties. Components are created by the macros (`domkit.Object` classes) and registered by name.
**/
class Component<BaseT,T> {

	/**
		The index of the component, used by the style cache (`-1` until it is used by a CSS rule).
	**/
	public var id = -1;
	/**
		The name of the component.
	**/
	public var name : String;
	/**
		Creates an object of the component, from the constructor arguments and the parent object.
	**/
	public var make : Array<Dynamic> -> BaseT -> T;
	/**
		The parent component: its properties are inherited, and its CSS rules apply.
	**/
	public var parent : Component<BaseT,Dynamic>;
	var propsHandler : Array<PropertyHandler<T,Dynamic>>;
	var classValue : Class<Dynamic>;

	/**
		Creates and registers the component.
	**/
	public function new(name, make, parent) {
		this.name = name;
		this.make = make;
		this.parent = parent;
		propsHandler = parent == null ? [] : cast parent.propsHandler;
		COMPONENTS.set(name, this);
	}

	/**
		Returns the handler of the property, or `null` if the component doesn't support it.
	**/
	public inline function getHandler<P>( p : Property ) : PropertyHandler<T,P> {
		return cast propsHandler[p.id];
	}

	/**
		Tells if the component is `c` or inherits from it.
	**/
	public function isOfType( c : Component<BaseT,T> ) {
		var me = this;
		do {
			if( me == c ) return true;
			me = cast me.parent;
			if( me == null ) return false;
		} while( true );
	}

	function addHandler<P>( p : String, parser : CssValue -> P, def : #if macro haxe.macro.Expr #else P #end, applyType : #if macro haxe.macro.Expr.ComplexType #else T -> P -> Void, ?transition #end ) {
		var ph = new PropertyHandler(parser,def,applyType);
		if( parent != null && propsHandler == cast parent.propsHandler ) propsHandler = propsHandler.copy();
		#if !macro
		@:privateAccess ph.transition = transition;
		#end
		propsHandler[Property.get(p).id] = ph;
		return ph;
	}

	/**
		Returns the component of the given name (after the remaps). Throws if unknown, or returns `null` if `opt` is set.
	**/
	public static function get( name : String, opt = false ) {
		name = resolveRemaps(name);
		var c = COMPONENTS.get(name);
		if( c == null && !opt ) throw "Unknown component "+name;
		return c;
	}

	#if !macro
	static var RUNTIME_REMAP : Map<String,String> = domkit.Macros.generateRemapMap();
	#end
	/**
		Returns the name of the component used for `name` (see `domkit.Macros.registerComponentRemap`), or `name` itself.
	**/
	public static function resolveRemaps( name : String ) : String {
		var newName = #if !macro RUNTIME_REMAP #else @:privateAccess Macros.COMPONENTS_REMAP_REV #end.get(name);
		if( newName != null )
			return newName;
		return name;
	}

	/**
		Creates the objects declared by an inline markup, and returns the root: `Component.build(<flow><text text="hi"/></flow>, parent)`.
	**/
	public static macro function build( expr, ?parent ) {
		switch( expr.expr ) {
		case EMeta({ name : ":markup" },{ expr : EConst(CString(str)) }):

			try {
				var p = new MarkupParser();
				var pinf = haxe.macro.Context.getPosInfos(expr.pos);
				var root = p.parse(str,pinf.file,pinf.min).children[0];

				var comp = switch( root.kind ) {
				case Node(name): @:privateAccess Macros.loadComponent(name, pinf.min, pinf.min + name.length);
				default: haxe.macro.Context.error("Should be a markup node", expr.pos);
				}

				var inf = { root : comp, fields : [], declaredIds : new Map(), inits : [], hasContent : false, useThis: false};
				var initExpr = @:privateAccess Macros.buildComponentsInit(root, inf, expr.pos, false);
				switch( initExpr.expr ) {
				case EBlock(el):
					var t = comp.baseType;
					var tcomp = @:privateAccess Macros.componentsType;
					el.unshift(parent == null || parent.expr.match(EConst(CIdent("null"))) ? macro var tmp : domkit.Properties<$tcomp> = null : macro @:pos(parent.pos) var tmp = $parent.dom);
					el.push(macro (cast tmp.obj : $t));
				default: throw "assert";
				}
				if( inf.inits.length > 0 ) {
					inf.inits.push({ expr : initExpr.expr, pos : initExpr.pos });
					initExpr.expr = EBlock(inf.inits);
				}
				return initExpr;

			} catch( e : Error ) {
				haxe.macro.Context.error(e.message, @:privateAccess Macros.makePos(expr.pos,e.pmin,e.pmax));
			}

		default:
			haxe.macro.Context.error("Should be a markup expression", expr.pos);
		}
		return null;
	}

	@:persistent static var COMPONENTS = new Map<String,Component<Dynamic,Dynamic>>();

}
