# domkit.BezierCurve

**class** · package [`domkit`](README.md) · module `domkit.CssParser` · source [`domkit/CssParser.hx`](../../../../domkit/CssParser.hx)

Extends: [`domkit.Curve`](Curve.md)

A cubic bezier easing curve, like CSS `cubic-bezier(c1x, c1y, c2x, c2y)`.

## Constructor

### new

```haxe
function new(a:Float, b:Float, c:Float, d:Float):Void
```

Creates the curve from its control points.

## Variables

### c1x

```haxe
var c1x:Float
```

The X of the first control point.

### c1y

```haxe
var c1y:Float
```

The Y of the first control point.

### c2x

```haxe
var c2x:Float
```

The X of the second control point.

### c2y

```haxe
var c2y:Float
```

The Y of the second control point.

## Methods

### interpolate

```haxe
override function interpolate(p:Float):Float
```

## Inherited members

- from [`domkit.Curve`](Curve.md): `interpolate`
