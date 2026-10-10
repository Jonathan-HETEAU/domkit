# domkit.Model

**interface** · package [`domkit`](README.md) · source [`domkit/Model.hx`](../../../../domkit/Model.hx)

Type parameters: `<T>`

The base type of the objects of the UI, `T` being the base class of the components: implement it on your base class (with Heaps, `h2d.Object` is used).

## Variables

### dom

```haxe
var dom:Properties<domkit.Model.T>
```

The DomKit properties of the object: component, classes, id, state and style.

### parent

```haxe
var parent(default, null):domkit.Model.T
```

The parent object, or `null`.

## Methods

### getChildren

```haxe
function getChildren():Array<domkit.Model.T>
```

Returns the children objects.

### getChildRefPosition

```haxe
function getChildRefPosition(first:Bool):Int
```

Returns the index of the first (or last if `first` is not set) child counting for the `:first-child`, `:last-child`, `:odd` and `:even` CSS pseudo classes.
