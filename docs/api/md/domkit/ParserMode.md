# domkit.ParserMode

**enum** · package [`domkit`](README.md) · module `domkit.MetaComponent` · source [`domkit/MetaComponent.hx`](../../../../domkit/MetaComponent.hx)

How the value of a `@:p` property is parsed.

## Constructors

### PNone

```haxe
PNone
```

`@:p(none)` or default: `none` is `null` for a nullable type.

### PAuto

```haxe
PAuto
```

`@:p(auto)`: `auto` is `null` for a nullable type.

### PCustom

```haxe
PCustom
```

`@:p(name)`: the `parse<Name>` method of the parser.
