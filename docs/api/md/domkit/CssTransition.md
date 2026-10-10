# domkit.CssTransition

**class** · package [`domkit`](README.md) · module `domkit.CssStyle` · source [`domkit/CssStyle.hx`](../../../../domkit/CssStyle.hx)

A running transition of a property of an object.

## Constructor

### new

```haxe
function new():Void
```

Creates the transition.

## Variables

### properties

```haxe
var properties:Properties<Dynamic>
```

The object.

### trans

```haxe
var trans:RuleTransition
```

The transition.

### handler

```haxe
var handler:PropertyHandler<Dynamic, Dynamic>
```

The handler applying the values.

### vstart

```haxe
var vstart:Dynamic
```

The start value.

### vtarget

```haxe
var vtarget:Dynamic
```

The target value.

### progress

```haxe
var progress:Float
```

The progress, from `0` to `1`.

### discrete

```haxe
var discrete:Bool
```

Tells if the value is not a number: it changes at the end of the transition (unless the handler interpolates it).
