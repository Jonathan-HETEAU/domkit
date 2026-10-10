# domkit.CssClass

**class** · package [`domkit`](README.md) · module `domkit.CssParser` · source [`domkit/CssParser.hx`](../../../../domkit/CssParser.hx)

A CSS selector part: component, class names, id and pseudo classes, with its parent selector.

## Constructor

### new

```haxe
function new():Void
```

Creates an empty selector.

## Variables

### parent

```haxe
var parent:Null<CssClass>
```

The parent selector, or `null`.

### component

```haxe
var component:Null<Component<Dynamic, Dynamic>>
```

The component, or `null` for any.

### id

```haxe
var id:Identifier
```

The id (`#id`), or undefined.

### className

```haxe
var className:Null<Identifier>
```

The class (`.name`), or `null`.

### extraClasses

```haxe
var extraClasses:Null<Array<Identifier>>
```

The other classes, or `null`.

### pseudoClasses

```haxe
var pseudoClasses:PseudoClass
```

The pseudo classes.

### relation

```haxe
var relation:CssRelation
```

The relation with the parent selector.

## Methods

### withParent

```haxe
function withParent(cl:CssClass):Null<CssClass>
```

Returns the selector of a nested rule, combined with its parent selector `cl`.

### toString

```haxe
function toString():String
```

Returns the selector in CSS syntax.
