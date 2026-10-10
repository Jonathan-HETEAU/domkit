# domkit.TypedComponent

**typedef** · package [`domkit`](README.md) · module `domkit.Checker` · source [`domkit/Checker.hx`](../../../../domkit/Checker.hx)

A component, with the types of its class, properties and constructor arguments.

## Fields

### properties

```haxe
var properties:Map<String, TypedProperty>
```

The properties declared by the component, by CSS name.

### parent

```haxe
var ?parent:Null<{ params:Array<hscript._Checker.Type>, comp:TypedComponent }>
```

The parent component.

### name

```haxe
var name:String
```

The name of the component.

### domkitComp

```haxe
var domkitComp:Component<Dynamic, Dynamic>
```

The runtime component.

### classDef

```haxe
var ?classDef:Null<hscript.CClass>
```

The class of the component.

### arguments

```haxe
var arguments:Array<{ t:hscript._Checker.Type, ?opt:Null<Bool>, name:String }>
```

The constructor arguments (without the parent).
