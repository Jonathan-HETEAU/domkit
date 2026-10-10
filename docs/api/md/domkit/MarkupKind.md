# domkit.MarkupKind

**enum** · package [`domkit`](README.md) · module `domkit.MarkupParser` · source [`domkit/MarkupParser.hx`](../../../../domkit/MarkupParser.hx)

The kind of a markup node.

## Constructors

### Node

```haxe
Node(name:String)
```

A component node (`<name>`), or the root of the document (`null` name).

### Text

```haxe
Text(text:String)
```

A text.

### CodeBlock

```haxe
CodeBlock(v:String)
```

Haxe code (`$ident` or `${ code }`), creating children.

### Macro

```haxe
Macro(id:String)
```

A macro call (`@name(args)`), expanded by `domkit.Macros.processMacro`.

### For

```haxe
For(cond:CodeExpr)
```

A loop (`for( x in a ) <node/>`, or with `{ }` for several children).
