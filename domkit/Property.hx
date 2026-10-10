package domkit;

/**
	Thrown by a property parser when the CSS value is invalid.
**/
class InvalidProperty {
	/**
		The reason, or `null`.
	**/
	public var message : String;
	/**
		Creates the exception.
	**/
	public function new(?msg) {
		this.message = msg;
	}
	/**
		Returns a description of the exception.
	**/
	public function toString() {
		return "InvalidProperty("+message+")";
	}
}

/**
	A CSS property name, registered once with a unique id (see `get`).
**/
class Property {
	/**
		The name of the property, in CSS casing (`padding-left`).
	**/
	public var name(default,null) : String;
	/**
		The unique id of the property.
	**/
	public var id(default,null) : Int;
	@:allow(domkit.CssStyle) var tag : Int = 0;
	@:allow(domkit.CssStyle) var transTag : Int = 0;
	/**
		Tells if a CSS rule defines a transition for the property.
	**/
	public var hasTransition(default,null) : Bool;

	function new(name) {
		this.id = ALL.length;
		this.name = name;
		ALL.push(this);
		MAP.set(name, this);
	}

	/**
		Returns the property of the given name, creating it if `create` is set (`null` otherwise).
	**/
	public static function get( name : String, create = true ) {
		if( MAP == null ) {
			MAP = new Map();
			ALL = [];
		}
		var p = MAP.get(name);
		if( p == null && create )
			p = new Property(name);
		return p;
	}

	@:persistent static var ALL : Array<Property>;
	@:persistent static var MAP : Map<String, Property>;

}