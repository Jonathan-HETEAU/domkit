# domkit.BytesCell

**class** · package [`domkit`](README.md) · module `domkit.CssStyle` · source [`domkit/CssStyle.hx`](../../../../domkit/CssStyle.hx) · available on hl

Type parameters: `<T>`

An entry of a `BytesMap`.

## Constructor

### new

```haxe
function new(bytes:hl.Bytes, value:domkit.BytesCell.T, next:BytesCell<domkit.BytesCell.T>):Void
```

Creates the entry.

## Variables

### bytes

```haxe
var bytes:hl.Bytes
```

The key.

### value

```haxe
var value:domkit.BytesCell.T
```

The value.

### next

```haxe
var next:BytesCell<domkit.BytesCell.T>
```

The next entry with the same hash.
