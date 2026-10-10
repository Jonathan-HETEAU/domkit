# domkit.Properties

**class** · package [`domkit`](README.md) · source [`domkit/Properties.hx`](../../../../domkit/Properties.hx)

Type parameters: `<T>`

The DomKit state of an object (its `dom` field): component, id, classes, pseudo class states (`hover`, `active`...) and the CSS values set on it. Changing them marks the object to be styled again by the next `applyStyle`.

## Constructor

### new

```haxe
function new(obj:Model<domkit.Properties.T>, component:Component<domkit.Properties.T, Dynamic>):Void
```

Creates the properties of the object.

## Static methods

### create

```haxe
static function create(comp:String, value:create.T, ?attributes:DynamicAccess<String>):Properties<create.BaseT>
```

Creates the properties of an existing object for the component of the given name, with optional attributes.

## Variables

### id

```haxe
var id(default, null):Identifier
```

The id of the object (`#id` in CSS), set with `setId`.

### obj

```haxe
var obj(default, null):Model<domkit.Properties.T>
```

The object.

### component

```haxe
var component(default, null):Component<domkit.Properties.T, Dynamic>
```

The component of the object.

### hover

```haxe
var hover(default, set):Bool
```

Matches the `:hover` pseudo class.

### active

```haxe
var active(default, set):Bool
```

Matches the `:active` pseudo class.

### disabled

```haxe
var disabled(default, set):Bool
```

Matches the `:disabled` pseudo class.

### focus

```haxe
var focus(default, set):Bool
```

Matches the `:focus` pseudo class.

### parent

```haxe
var parent(get, null):Properties<domkit.Properties.T>
```

The properties of the parent object, or `null`.

### contentRoot

```haxe
var contentRoot(default, null):Model<domkit.Properties.T>
```

The object to which the children declared in the markup are added (the object itself by default).

## Methods

### getClasses

```haxe
function getClasses():Iterable<Identifier>
```

Returns the classes of the object.

### hasClass

```haxe
function hasClass(name:String):Bool
```

Tells if the object has the class.

### onParentChanged

```haxe
function onParentChanged(?prev:Properties<domkit.Properties.T>):Void
```

Must be called when the object is added to or removed from a parent, to style it again.

### addClass

```haxe
function addClass(c:String):Void
```

Adds a class.

### applyStyle

```haxe
function applyStyle(style:CssStyle):Void
```

Applies the style to the objects that need it, from this object's tree.

### removeClass

```haxe
function removeClass(c:String):Void
```

Removes a class.

### toggleClass

```haxe
function toggleClass(c:String, ?b:Bool):Void
```

Adds the class if `b` is set, removes it if `b` is `false`, or toggles it if `b` is `null`.

### initAttributes

```haxe
function initAttributes(attr:DynamicAccess<String>):Void
```

Sets the attributes from their CSS strings (see `setAttribute`). Invalid ones are printed on `sys` targets.

### setClasses

```haxe
function setClasses(?classStr:String, ?classObj:Dynamic<Bool>):Void
```

Replaces the classes, from a string (`"a b"`) or from an object whose fields set to `true` are the classes (`_` becoming `-`).

### appendClasses

```haxe
function appendClasses(?classStr:String, ?classObj:Dynamic<Bool>):Void
```

Adds classes, from a string (`"a b"`) or from an object whose fields set to `true` are the classes (`_` becoming `-`).

### setClassKind

```haxe
function setClassKind(kind:String, value:String):Void
```

Removes the class starting with `kind-` and adds the class `kind-value` instead (none if `value` is `null`).

### setId

```haxe
function setId(id:String):Void
```

Sets the id of the object, or `null`.

### setAttribute

```haxe
function setAttribute(p:String, value:CssValue):SetAttributeResult
```

Sets a property of the object, as an inline style (it has priority over the CSS rules), and applies it. `id` and `class` set the id and add classes.
