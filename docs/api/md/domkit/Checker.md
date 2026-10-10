# domkit.Checker

**class** · package [`domkit`](README.md) · source [`domkit/Checker.hx`](../../../../domkit/Checker.hx)

Extends: `hscript.Checker`

Type checks the markup and the CSS of components at runtime (for the interpreted components of `Interp`, or in editors such as Hide), from the types of the Heaps components (`h2d.domkit.InitComponents.build()` classes).

## Constructor

### new

```haxe
function new(types:Null<hscript.CheckerTypes>):Void
```

Creates the checker from the types of the program (`hscript.LiveClass.getTypes()`).

## Variables

### t_string

```haxe
var t_string:hscript._Checker.Type
```

The `String` type.

### components

```haxe
var components:Map<String, TypedComponent>
```

The components, by name.

### properties

```haxe
var properties:Map<String, Array<TypedProperty>>
```

The components properties, by CSS name.

## Methods

### begin

```haxe
function begin(onMarkup:(String, hscript._Expr.Expr) -> Void):Void
```

Starts checking code, `onMarkup` being called for the markup expressions.

### done

```haxe
function done():Void
```

Ends the checking.

### haxeToCss

```haxe
function haxeToCss(name:String):String
```

Converts a Haxe name to CSS casing (see `CssParser.haxeToCss`).

### getComponent

```haxe
function getComponent(name:String):Null<TypedComponent>
```

Returns the component of the given name (after the remaps), or `null`.

### makeParams

```haxe
function makeParams(c:TypedComponent):Null<Array<hscript._Checker.Type>>
```

Returns new monomorphs for the type parameters of the component class, or `null`.

### resolveProperty

```haxe
function resolveProperty(comp:TypedComponent, name:String):Null<TypedProperty>
```

Returns the property of the component or of its parents, or `null`.
