# domkit.CssValue

**enum** · package [`domkit`](README.md) · source [`domkit/CssValue.hx`](../../../../domkit/CssValue.hx)

A parsed CSS value.

## Constructors

### VIdent

```haxe
VIdent(i:String)
```

An identifier.

### VString

```haxe
VString(s:String)
```

A quoted string.

### VUnit

```haxe
VUnit(v:Float, unit:String)
```

A number with a unit (`10px`, `50%`).

### VFloat

```haxe
VFloat(v:Float)
```

A float.

### VInt

```haxe
VInt(v:Int)
```

An integer.

### VHex

```haxe
VHex(h:String, v:Int)
```

A hexadecimal color (`#F80`), with its digits and value.

### VList

```haxe
VList(l:Array<CssValue>)
```

Values separated by commas.

### VGroup

```haxe
VGroup(l:Array<CssValue>)
```

Values separated by spaces.

### VCall

```haxe
VCall(f:String, vl:Array<CssValue>)
```

A function call (`rgba(...)`, `url(...)`).

### VLabel

```haxe
VLabel(v:String, val:CssValue)
```

A value with a label (`!important`).

### VSlash

```haxe
VSlash
```

A `/` separator.

### VArray

```haxe
VArray(v:CssValue, ?content:CssValue)
```

An array access (`a[b]`).

### VOp

```haxe
VOp(op:CssOp, v1:CssValue, v2:CssValue)
```

An arithmetic operation.

### VParent

```haxe
VParent(v:CssValue)
```

A value in parentheses.

### VVar

```haxe
VVar(name:String)
```

A variable (`@name`).
