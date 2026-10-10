# domkit.Curve

**class** · package [`domkit`](README.md) · module `domkit.CssParser` · source [`domkit/CssParser.hx`](../../../../domkit/CssParser.hx)

Subclasses: [`domkit.BezierCurve`](BezierCurve.md)

An easing curve: linear.

## Constructor

### new

```haxe
function new():Void
```

Creates the curve.

## Methods

### interpolate

```haxe
function interpolate(v:Float):Float
```

Returns the progress of the value at the time `v` (from `0` to `1`).
