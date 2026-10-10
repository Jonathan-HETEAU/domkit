# domkit.ValueParser

**class** · package [`domkit`](README.md) · module `domkit.CssValue` · source [`domkit/CssValue.hx`](../../../../domkit/CssValue.hx)

Converts CSS values to property values: the `parseXxx` methods are used by the `@:p(xxx)` fields (`@:p(color)` uses `parseColor`). Extend it to add parsers, and set it with `@:parser` or `domkit.Macros.setDefaultParser`. The methods throw `Property.InvalidProperty` for invalid values.

## Constructor

### new

```haxe
function new():Void
```

Creates the parser.

## Methods

### invalidProp

```haxe
function invalidProp(?msg:String):Dynamic
```

Throws an `Property.InvalidProperty` error.

### parseIdent

```haxe
function parseIdent(v:CssValue):String
```

Parses an identifier.

### parseString

```haxe
function parseString(v:CssValue):String
```

Parses a string or an identifier.

### parseId

```haxe
function parseId(v:CssValue):String
```

Parses an object id.

### parseColor

```haxe
function parseColor(v:CssValue):Int
```

Parses a color, as an ARGB integer: `#RGB`, `#RRGGBB`, `rgb(r,g,b)`, `rgba(r,g,b,a)`, CSS color names, `darken(c,10%)`, `lighten(c,10%)`, `saturate(c,10%)`, `desaturate(c,10%)`, and `color alpha`.

### transitionColor

```haxe
function transitionColor(a:Null<Int>, b:Null<Int>, p:Float):Int
```

Interpolates between two ARGB colors.

### parseArray

```haxe
function parseArray(elt:() -> parseArray.T, v:CssValue):Array<parseArray.T>
```

Parses values separated by spaces, with `elt`.

### parsePath

```haxe
function parsePath(v:CssValue):String
```

Parses a path: a string, an identifier or `url(path)`.

### parseBool

```haxe
function parseBool(v:CssValue):Null<Bool>
```

Parses a boolean: `true`, `false`, `1` or `0`.

### parseAuto

```haxe
function parseAuto(either:() -> parseAuto.T, v:CssValue):Null<parseAuto.T>
```

Returns `null` for `auto`, or parses the value with `either`.

### parseNone

```haxe
function parseNone(either:() -> parseNone.T, v:CssValue):Null<parseNone.T>
```

Returns `null` for `none`, or parses the value with `either`.

### parseInt

```haxe
function parseInt(v:CssValue):Null<Int>
```

Parses an integer.

### parseFloat

```haxe
function parseFloat(v:CssValue):Float
```

Parses a number.

### parseFloatPercent

```haxe
function parseFloatPercent(v:CssValue):Float
```

Parses a number, or a percentage as a ratio (`50%` is `0.5`).

### parseXY

```haxe
function parseXY(v:CssValue):{ y:Float, x:Float }
```

Parses two numbers, as `{ x, y }`.

### parseBox

```haxe
function parseBox(v:CssValue):{ top:Int, right:Int, left:Int, bottom:Int }
```

Parses 1 to 4 integers as `{ top, right, bottom, left }`, like the CSS `padding`.

### parseGenBox

```haxe
function parseGenBox(v:CssValue, f:() -> parseGenBox.T):{ top:parseGenBox.T, right:parseGenBox.T, left:parseGenBox.T, bottom:parseGenBox.T }
```

Parses 1 to 4 values with `f`, as `{ top, right, bottom, left }`, like the CSS `padding`.

### makeEnumParser

```haxe
function makeEnumParser(e:Enum<makeEnumParser.T>):() -> makeEnumParser.T
```

Returns a parser of the constructors of the enum, in CSS casing (`TopLeft` is `top-left`) or lower case.
