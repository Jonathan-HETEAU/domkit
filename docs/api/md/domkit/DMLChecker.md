# domkit.DMLChecker

**class** · package [`domkit`](README.md) · module `domkit.Checker` · source [`domkit/Checker.hx`](../../../../domkit/Checker.hx)

Parses and type checks the markup of a component (DML), and checks CSS rules against the components.

## Constructor

### new

```haxe
function new(checker:Checker):Void
```

Creates the checker.

## Variables

### parsers

```haxe
var parsers:Array<ValueParser>
```

The value parsers used to check the CSS values.

### definedIdents

```haxe
var definedIdents:Map<String, Array<TypedComponent>>
```

The components using each id (`#id`) or class, to check the CSS rules using them.

## Methods

### loadFile

```haxe
dynamic function loadFile(path:String):Null<String>
```

Returns the content of a file (for the `import.hx` files), or `null`.

### parse

```haxe
function parse(data:String, filePath:String, filePos:Int, locals:{  }):Markup
```

Parses and checks the markup of a component, with the types of the `locals` (see `domkit.Macros.generateLocalsObj`). Throws an error if invalid.

### defineIdent

```haxe
function defineIdent(c:TypedComponent, cl:String):Void
```

Registers a component using the id or class `cl`.

### checkCSS

```haxe
function checkCSS(rules:CssSheet):Void
```

Checks the properties of the rules against the components they apply to.
