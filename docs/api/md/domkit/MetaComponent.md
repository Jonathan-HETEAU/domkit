# domkit.MetaComponent

**class** · package [`domkit`](README.md) · source [`domkit/MetaComponent.hx`](../../../../domkit/MetaComponent.hx)

Extends: [`domkit.Component`](Component.md)

The component of a `domkit.Object` class at compile time: reads its `@:p` properties and constructor, and generates its runtime `Component`.

## Constructor

### new

```haxe
function new(name:String, make:(Array<Dynamic>, Dynamic) -> Dynamic, parent:Component<Dynamic, Dynamic>):Void
```

## Inherited members

- from [`domkit.Component`](Component.md): `id`, `name`, `make`, `parent`, `getHandler`, `isOfType`
