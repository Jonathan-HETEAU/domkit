# domkit.HSL

**class** · package [`domkit`](README.md) · module `domkit.CssValue` · source [`domkit/CssValue.hx`](../../../../domkit/CssValue.hx)

A color in the HSL color space, used by the `darken`, `lighten`, `saturate` and `desaturate` color functions.

## Constructor

### new

```haxe
function new(color:Int):Void
```

Converts an ARGB color.

## Variables

### alpha

```haxe
var alpha:Float
```

The alpha, from `0` to `1`.

### hue

```haxe
var hue:Float
```

The hue, in radians.

### saturation

```haxe
var saturation:Float
```

The saturation, from `0` to `1`.

### lightness

```haxe
var lightness:Float
```

The lightness, from `0` to `1`.

## Methods

### toColor

```haxe
function toColor():Int
```

Returns the ARGB color.
