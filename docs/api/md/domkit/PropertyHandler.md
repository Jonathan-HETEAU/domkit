# domkit.PropertyHandler

**class** · package [`domkit`](README.md) · module `domkit.Component` · source [`domkit/Component.hx`](../../../../domkit/Component.hx)

Type parameters: `<O, P>`

How a component handles a CSS property: parses its value, applies it to the objects of type `O`, and interpolates it for the transitions.

## Constructor

### new

```haxe
function new(parser:() -> domkit.PropertyHandler.P, def:domkit.PropertyHandler.P, applyType:(domkit.PropertyHandler.O, domkit.PropertyHandler.P) -> Void):Void
```

Creates the handler.

## Variables

### parser

```haxe
var parser(default, null):() -> domkit.PropertyHandler.P
```

Converts the CSS value to the property value. Throws `Property.InvalidProperty` if invalid.

### defaultValue

```haxe
var defaultValue(default, null):domkit.PropertyHandler.P
```

The value applied when no CSS rule sets the property.

### apply

```haxe
var apply(default, null):(domkit.PropertyHandler.O, domkit.PropertyHandler.P) -> Void
```

Applies the value to an object.

### transition

```haxe
var transition(default, null):(domkit.PropertyHandler.P, domkit.PropertyHandler.P, Float) -> domkit.PropertyHandler.P
```

Interpolates between two values, or `null` (floats are interpolated, other values change at the end of the transition).
