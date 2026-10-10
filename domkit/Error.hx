package domkit;

/**
	An error while parsing markup or CSS, with its position in the source.
**/
class Error {
	/**
		The error message.
	**/
	public var message : String;
	/**
		The start position in the source, or `-1`.
	**/
	public var pmin : Int;
	/**
		The end position in the source.
	**/
	public var pmax : Int;

	/**
		Creates the error. `pmax` defaults to `pmin + 1`.
	**/
	public function new( messsage, pmin = -1, pmax = -1 ) {
		this.message = messsage;
		this.pmin = pmin;
		this.pmax = pmax < 0 ? pmin + 1 : pmax;
	}

	/**
		Returns a description of the error.
	**/
	public function toString() {
		var msg = "UIKitError("+message+")";
		if( pmin < 0 )
			return msg;
		msg += " "+pmin;
		if( pmax == pmin )
			return msg;
		msg += ":"+(pmax - pmin);
		return msg;
	}

}