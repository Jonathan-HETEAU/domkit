# domkit.CssRelation

**enum abstract** · package [`domkit`](README.md) · module `domkit.CssParser` · source [`domkit/CssParser.hx`](../../../../domkit/CssParser.hx)

The relation between a selector and its parent selector.

Underlying type: `Int`

## Values

| Name | Value | Description |
|---|---|---|
| `None` | `0` | A descendant (`a b`). |
| `ImmediateChildren` | `1` | A direct child (`a > b`). |
| `SubRule` | `2` | The same object, in a nested rule (`&.b`). |
