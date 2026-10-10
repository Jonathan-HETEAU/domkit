# domkit.AttributeValue

**enum** · package [`domkit`](README.md) · module `domkit.MarkupParser` · source [`domkit/MarkupParser.hx`](../../../../domkit/MarkupParser.hx)

The value of an attribute or argument.

## Constructors

### RawValue

```haxe
RawValue(v:String)
```

A string, parsed as CSS (`attr="value"`).

### Code

```haxe
Code(v:CodeExpr)
```

Haxe code (`attr={code}`, or `"$code"`).
