# domkit.CssData

**class** · package [`domkit`](README.md) · module `domkit.CssStyle` · source [`domkit/CssStyle.hx`](../../../../domkit/CssStyle.hx)

The rules of a `CssStyle`, sorted by priority, and the cache of the rules matching a set of components.

## Constructor

### new

```haxe
function new():Void
```

Creates empty data.

## Static variables

### CID

```haxe
static var CID:Int
```

The number of components with an id.

### COMPONENTS

```haxe
static var COMPONENTS:Array<Component<Dynamic, Dynamic>>
```

The components used by the rules, by id.

## Static methods

### registerComponent

```haxe
static function registerComponent(c:Component<Dynamic, Dynamic>):Void
```

Gives an id to the component, if not done yet.

## Variables

### rules

```haxe
var rules:Array<Rule>
```

The rules, sorted by decreasing priority after `init`.

### bytesSize

```haxe
var bytesSize:Int
```

The size of the component bit sets.

### needsInit

```haxe
var needsInit:Bool
```

Tells if rules were added since the last `init`.

## Methods

### init

```haxe
function init():Void
```

Sorts the rules and registers their components, if rules were added.

### getCache

```haxe
inline function getCache(bits:FastBytes):Array<Rule>
```

Returns the rules cached for the set of components, or `null`.

### setCache

```haxe
inline function setCache(bits:FastBytes, value:Array<Rule>):Void
```

Caches the rules of the set of components.

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
