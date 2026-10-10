# domkit.RuleStyle

**class** · package [`domkit`](README.md) · module `domkit.CssStyle` · source [`domkit/CssStyle.hx`](../../../../domkit/CssStyle.hx)

A property set by a `Rule`.

## Constructor

### new

```haxe
function new(p:Property, value:CssValue, ?pos:{ vmin:Int, pmin:Int, pmax:Int, file:String }):Void
```

Creates the property.

## Variables

### p

```haxe
var p:Property
```

The property.

### value

```haxe
var value:CssValue
```

The CSS value.

### lastHandler

```haxe
var lastHandler:PropertyHandler<Dynamic, Dynamic>
```

The handler that last parsed the value, to reuse `lastValue`.

### lastValue

```haxe
var lastValue:Dynamic
```

The value parsed by `lastHandler`.

### next

```haxe
var next:RuleStyle
```

The next property applied to the object (temporary list).

### pos

```haxe
var pos:{ vmin:Int, pmin:Int, pmax:Int, file:String }
```

The position in the CSS source, or `null`.
