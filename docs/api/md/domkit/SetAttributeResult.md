# domkit.SetAttributeResult

**enum** · package [`domkit`](README.md) · module `domkit.Properties` · source [`domkit/Properties.hx`](../../../../domkit/Properties.hx)

The result of `Properties.setAttribute`.

## Constructors

### Ok

```haxe
Ok
```

The value was applied.

### Unknown

```haxe
Unknown
```

The property is unknown.

### Unsupported

```haxe
Unsupported
```

The component doesn't support the property.

### InvalidValue

```haxe
InvalidValue(?msg:String)
```

The value is invalid for the property.
