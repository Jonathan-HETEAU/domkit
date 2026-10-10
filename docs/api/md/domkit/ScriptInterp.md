# domkit.ScriptInterp

**class** · package [`domkit`](README.md) · module `domkit.Interp` · source [`domkit/Interp.hx`](../../../../domkit/Interp.hx)

Extends: `hscript.Interp`

The hscript interpreter running the code of an interpreted component.

## Constructor

### new

```haxe
function new(ctx:Interp, obj:Model<Dynamic>, locals:{  }):Void
```

Creates the interpreter of the object, with the local variables of its constructor.

## Methods

### executeLoop

```haxe
function executeLoop(n:String, it:hscript.Expr, callb:() -> Void):Void
```

Runs `callb` for each value of the iterator, as the variable `n`.

### executeKeyValueLoop

```haxe
function executeKeyValueLoop(vk:String, vv:String, it:hscript.Expr, callb:() -> Void):Void
```

Runs `callb` for each key and value of the iterator, as the variables `vk` and `vv`.
