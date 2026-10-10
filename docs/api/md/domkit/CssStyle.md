# domkit.CssStyle

**class** · package [`domkit`](README.md) · source [`domkit/CssStyle.hx`](../../../../domkit/CssStyle.hx)

A style: CSS rules applied to objects with `Properties.applyStyle`, and the running transitions, updated with `updateTime`.

## Constructor

### new

```haxe
function new():Void
```

Creates an empty style.

## Static methods

### ruleMatch

```haxe
static function ruleMatch(c:CssClass, e:Properties<Dynamic>):Bool
```

Tells if the selector matches the object.

## Variables

### data

```haxe
var data:CssData
```

The rules.

### useSmartCache

```haxe
var useSmartCache:Bool
```

Caches the rules matching each set of components of an object and its parents, to test fewer rules.

## Methods

### updateTime

```haxe
function updateTime(dt:Float):Void
```

Updates the running transitions, `dt` being the elapsed time in seconds.

### add

```haxe
function add(sheet:CssSheet):Void
```

Adds the rules of a style sheet.

### clear

```haxe
function clear():Void
```

Removes all the rules.
