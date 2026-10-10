# domkit.Token

**enum** · package [`domkit`](README.md) · module `domkit.CssParser` · source [`domkit/CssParser.hx`](../../../../domkit/CssParser.hx)

A token of the CSS lexer.

## Constructors

### TIdent

```haxe
TIdent(i:String)
```

An identifier.

### TString

```haxe
TString(s:String)
```

A quoted string.

### TInt

```haxe
TInt(i:Int)
```

An integer.

### TFloat

```haxe
TFloat(f:Float)
```

A float.

### TDblDot

```haxe
TDblDot
```

`:`

### TSharp

```haxe
TSharp
```

`#`

### TPOpen

```haxe
TPOpen
```

`(`

### TPClose

```haxe
TPClose
```

`)`

### TExclam

```haxe
TExclam
```

`!`

### TComma

```haxe
TComma
```

`,`

### TEof

```haxe
TEof
```

The end of the input.

### TPercent

```haxe
TPercent
```

`%`

### TSemicolon

```haxe
TSemicolon
```

`;`

### TBrOpen

```haxe
TBrOpen
```

`{`

### TBrClose

```haxe
TBrClose
```

`}`

### TDot

```haxe
TDot
```

`.`

### TSpaces

```haxe
TSpaces
```

Spaces (in selectors).

### TSlash

```haxe
TSlash
```

`/`

### TStar

```haxe
TStar
```

`*`

### TPlus

```haxe
TPlus
```

`+`

### TMinus

```haxe
TMinus
```

`-`

### TBkOpen

```haxe
TBkOpen
```

`[`

### TBkClose

```haxe
TBkClose
```

`]`

### TSuperior

```haxe
TSuperior
```

`>`

### TAnd

```haxe
TAnd
```

`&`

### TAt

```haxe
TAt
```

`@`
