# domkit.MarkupParser

**class** · package [`domkit`](README.md) · source [`domkit/MarkupParser.hx`](../../../../domkit/MarkupParser.hx)

Parses the XML-like markup of the components (`static var SRC = <comp>...</comp>`).

## Constructor

### new

```haxe
function new():Void
```

Creates a parser.

## Static methods

### markupToString

```haxe
static function markupToString(m:Markup):String
```

Returns the markup source of a node.

## Variables

### allowRawText

```haxe
var allowRawText:Bool
```

Accepts the code blocks that are not loops as raw text, instead of failing.

## Methods

### parse

```haxe
function parse(str:String, fileName:String, filePos:Int):Markup
```

Parses the markup and returns its root, whose children are the top nodes. `filePos` is added to the positions of the nodes and errors.
