# domkit.CssParser

**class** · package [`domkit`](README.md) · source [`domkit/CssParser.hx`](../../../../domkit/CssParser.hx)

Parses CSS style sheets and values, with the DomKit extensions: nested rules (`&`, `>`), variables (`@name : value;`), mixins (`.name(args) { }` used as `.name(values);`), arithmetic, and `//` comments.

## Constructor

### new

```haxe
function new():Void
```

Creates a parser.

## Static methods

### opStr

```haxe
static function opStr(op:CssOp):String
```

Returns the CSS operator.

### valueMap

```haxe
static function valueMap(v:CssValue, f:() -> CssValue):CssValue
```

Returns the value with `f` applied to its sub values.

### valueStr

```haxe
static function valueStr(v:CssValue):String
```

Returns the value in CSS syntax.

### haxeToCss

```haxe
static function haxeToCss(name:String):String
```

Converts a Haxe name to CSS casing: `myButton` and `MyButton` are `my-button`. Fully uppercase names are lower cased, and `_` becomes `-`.

### cssToHaxe

```haxe
static function cssToHaxe(name:String, ?isField:Bool = false):String
```

Converts a CSS name to a Haxe class name (`my-button` is `MyButton`), or a field name if `isField` is set (`myButton`).

## Variables

### warnings

```haxe
var warnings:Array<{ pmin:Int, pmax:Int, msg:String }>
```

The warnings of the last parsing or `check`.

### allowSubRules

```haxe
var allowSubRules:Bool
```

Allows nested rules.

### allowVariablesDecl

```haxe
var allowVariablesDecl:Bool
```

Allows variables declarations (`@name : value;`).

### allowMixins

```haxe
var allowMixins:Bool
```

Allows mixins.

### expandSubRules

```haxe
var expandSubRules:Bool
```

Converts the nested rules to rules with full selectors.

### allowSingleLineComment

```haxe
var allowSingleLineComment:Bool
```

Allows `//` comments.

### variables

```haxe
var variables:Map<String, CssValue>
```

The variables, by name.

### mixins

```haxe
var mixins:Map<String, { rules:CssSheetElement, args:Array<String> }>
```

The mixins, by name.

## Methods

### addMacro

```haxe
function addMacro(name:String, callb:(args:Array<CssValue>, parent:CssSheetElement) -> String):Void
```

Adds a macro, used like a mixin (`.name(args);`): `callb` returns CSS code inserted in the rule.

### error

```haxe
function error(msg:String):Dynamic
```

Throws an `Error` at the current position.

### parse

```haxe
function parse(css:String, ?file:String):CssSheetElement
```

Parses the properties of an inline style (without selector).

### parseValue

```haxe
function parseValue(valueStr:String):CssValue
```

Parses a CSS value.

### parseSheet

```haxe
function parseSheet(css:String, ?file:String):CssSheet
```

Parses a style sheet.

### parseClasses

```haxe
function parseClasses(css:String, ?hasParent:Bool, ?file:String):Array<CssClass>
```

Parses selectors.

### check

```haxe
function check(rules:CssSheet, components:Array<Component<Dynamic, Dynamic>>):Void
```

Checks that the properties of the rules are supported by their components and have valid values: the problems are added to `warnings`.
