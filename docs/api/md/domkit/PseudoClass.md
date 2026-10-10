# domkit.PseudoClass

**enum abstract** · package [`domkit`](README.md) · module `domkit.CssParser` · source [`domkit/CssParser.hx`](../../../../domkit/CssParser.hx)

The pseudo classes of a CSS selector, as bit flags.

Underlying type: `Int`

## Values

| Name | Value | Description |
|---|---|---|
| `None` | `0` | No pseudo class. |
| `Hover` | `1` | `:hover`: the object is hovered (`Properties.hover`). |
| `FirstChild` | `2` | `:first-child`. |
| `LastChild` | `4` | `:last-child`. |
| `Odd` | `8` | `:odd`: the children at an odd index, counting from 0. |
| `Even` | `16` | `:even`: the children at an even index, counting from 0. |
| `Active` | `32` | `:active` (`Properties.active`). |
| `Disabled` | `64` | `:disabled` (`Properties.disabled`). |
| `Focus` | `128` | `:focus` (`Properties.focus`). |
| `NotImportant` | `256` | `:not-important`: lowers the priority of the rule below the rules without it. |
| `NeedChildren` | `512` | Set with the pseudo classes depending on the position among the parent's children. |

## Methods

### toInt

```haxe
inline function toInt():Int
```

Returns the flags as an integer.

### has

```haxe
inline function has(c:PseudoClass):Bool
```

Tells if the flag is set.
