# domkit.Component

**class** · package [`domkit`](README.md) · source [`domkit/Component.hx`](../../../../domkit/Component.hx)

Type parameters: `<BaseT, T>`

Subclasses: [`domkit.MetaComponent`](MetaComponent.md)

A component: the name used in the markup and in CSS (`button`, `flow`...), how to create its objects of type `T`, and how it handles the CSS properties. Components are created by the macros (`domkit.Object` classes) and registered by name.

## Constructor

### new

```haxe
function new(name:String, make:(Array<Dynamic>, domkit.Component.BaseT) -> domkit.Component.T, parent:Component<domkit.Component.BaseT, Dynamic>):Void
```

Creates and registers the component.

## Static methods

### get

```haxe
static function get(name:String, ?opt:Bool = false):Null<Component<Dynamic, Dynamic>>
```

Returns the component of the given name (after the remaps). Throws if unknown, or returns `null` if `opt` is set.

### resolveRemaps

```haxe
static function resolveRemaps(name:String):String
```

Returns the name of the component used for `name` (see `domkit.Macros.registerComponentRemap`), or `name` itself.

### build

```haxe
static function build(expr:Dynamic, ?parent:Dynamic):Dynamic
```

Creates the objects declared by an inline markup, and returns the root: `Component.build(<flow><text text="hi"/></flow>, parent)`.

## Variables

### id

```haxe
var id:Int
```

The index of the component, used by the style cache (`-1` until it is used by a CSS rule).

### name

```haxe
var name:String
```

The name of the component.

### make

```haxe
var make:(Array<Dynamic>, domkit.Component.BaseT) -> domkit.Component.T
```

Creates an object of the component, from the constructor arguments and the parent object.

### parent

```haxe
var parent:Component<domkit.Component.BaseT, Dynamic>
```

The parent component: its properties are inherited, and its CSS rules apply.

## Methods

### getHandler

```haxe
inline function getHandler(p:Property):PropertyHandler<domkit.Component.T, getHandler.P>
```

Returns the handler of the property, or `null` if the component doesn't support it.

### isOfType

```haxe
function isOfType(c:Component<domkit.Component.BaseT, domkit.Component.T>):Bool
```

Tells if the component is `c` or inherits from it.
