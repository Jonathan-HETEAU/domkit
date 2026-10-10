# domkit.Markup

**typedef** · package [`domkit`](README.md) · module `domkit.MarkupParser` · source [`domkit/MarkupParser.hx`](../../../../domkit/MarkupParser.hx)

A node of the markup tree.

## Fields

### pmin

```haxe
var pmin:Int
```

The start position in the source.

### pmax

```haxe
var pmax:Int
```

The end position in the source.

### parent

```haxe
var ?parent:Null<{ pmin:Int, pmax:Int, name:String, arguments:Array<Argument> }>
```

The parent component of a component definition (`<name:parent(args)>`).

### kind

```haxe
var kind:MarkupKind
```

The kind of node.

### condition

```haxe
var ?condition:Null<{ pmin:Int, pmax:Int, cond:CodeExpr }>
```

The condition (`<node if(cond)>`): the node is created only if it is true.

### children

```haxe
var ?children:Null<Array<Markup>>
```

The children.

### attributes

```haxe
var ?attributes:Null<Array<{ vmin:Int, value:AttributeValue, pmin:Int, pmax:Int, name:String }>>
```

The attributes.

### arguments

```haxe
var ?arguments:Null<Array<Argument>>
```

The arguments (`<node(args)>`).
