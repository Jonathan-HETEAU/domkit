package domkit;

/**
	A string (class name or id) converted to a unique integer, for fast comparisons.
**/
abstract Identifier(Int) {
	/**
		Returns the identifier of the string.
	**/
	public function new(name:String) {
		this = _CACHE.get(name);
		if( !isDefined() ) {
			this = ++_UID;
			_CACHE.set(name, this);
			_RCACHE.push(name);
		}
	}
	/**
		Returns the string of the identifier.
	**/
	public function toString() {
		return _RCACHE[this];
	}
	/**
		Tells if the identifier is set (not `null`).
	**/
	public inline function isDefined() {
		return this != #if static 0 #else null #end;
	}
	static var _UID = 0;
	static var _CACHE = new Map();
	static var _RCACHE = [null];
}