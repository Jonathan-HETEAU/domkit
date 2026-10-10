package domkit;

#if domkit_heaps
/**
	The base type of the objects of the UI: `h2d.Object` with Heaps (`-D domkit_heaps`).
**/
typedef Model<T> = h2d.Object;
#else
/**
	The base type of the objects of the UI, `T` being the base class of the components: implement it on your base class (with Heaps, `h2d.Object` is used).
**/
interface Model<T:Model<T>> {
	/**
		The DomKit properties of the object: component, classes, id, state and style.
	**/
	var dom : Properties<T>;
	/**
		The parent object, or `null`.
	**/
	var parent(default,never) : T;
	/**
		Returns the children objects.
	**/
	function getChildren() : Array<T>;
	/**
		Returns the index of the first (or last if `first` is not set) child counting for the `:first-child`, `:last-child`, `:odd` and `:even` CSS pseudo classes.
	**/
	function getChildRefPosition( first : Bool ) : Int;
}
#end
