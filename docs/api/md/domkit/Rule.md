# domkit.Rule

**class** · package [`domkit`](README.md) · module `domkit.CssStyle` · source [`domkit/CssStyle.hx`](../../../../domkit/CssStyle.hx)

A CSS rule for one selector, with its priority.

## Constructor

### new

```haxe
function new():Void
```

Creates an empty rule.

## Variables

### id

```haxe
var id:Int
```

The index of the rule, to keep the declaration order among rules of equal priority.

### priority

```haxe
var priority:Int
```

The priority, from the specificity of the selector (ids, then classes and pseudo classes, then components) and `!important`.

### cl

```haxe
var cl:CssClass
```

The selector.

### style

```haxe
var style:Array<RuleStyle>
```

The properties.

### transitions

```haxe
var transitions:Array<RuleTransition>
```

The transitions, or `null`.
