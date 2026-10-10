# domkit.Property

**class** · package [`domkit`](README.md) · source [`domkit/Property.hx`](../../../../domkit/Property.hx)

A CSS property name, registered once with a unique id (see `get`).

## Static methods

### get

```haxe
static function get(name:String, ?create:Bool = true):Null<Property>
```

Returns the property of the given name, creating it if `create` is set (`null` otherwise).

## Variables

### name

```haxe
var name(default, null):String
```

The name of the property, in CSS casing (`padding-left`).

### id

```haxe
var id(default, null):Int
```

The unique id of the property.

### hasTransition

```haxe
var hasTransition(default, null):Bool
```

Tells if a CSS rule defines a transition for the property.
