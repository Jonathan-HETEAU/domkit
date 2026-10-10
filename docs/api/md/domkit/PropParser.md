# domkit.PropParser

**enum** · package [`domkit`](README.md) · module `domkit.Checker` · source [`domkit/Checker.hx`](../../../../domkit/Checker.hx)

How a property value is parsed, for the type checking of CSS values.

## Constructors

### PUnknown

```haxe
PUnknown
```

Unknown parser: the value is not checked.

### PNamed

```haxe
PNamed(name:String)
```

The `parse<Name>` method of the `ValueParser`.

### POpt

```haxe
POpt(t:PropParser, def:String)
```

A nullable value, where `def` (`auto` or `none`) means `null`.

### PEnum

```haxe
PEnum(e:hscript.CEnum)
```

The constructors of an enum.
