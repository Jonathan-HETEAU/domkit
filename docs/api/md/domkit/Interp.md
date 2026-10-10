# domkit.Interp

**class** · package [`domkit`](README.md) · source [`domkit/Interp.hx`](../../../../domkit/Interp.hx)

Runs the markup of components with hscript instead of compiled code, to reload it while the program runs (hot reload). Enable it with `domkit.Macros.allowInterp()` (after `hscript.LiveClass.enable()`), and compile with `-lib hscript -D hscriptPos`.

## Static variables

### onError

```haxe
static var onError:(msg:String) -> Void
```

Called on errors, if set (errors are thrown otherwise).

## Static methods

### getChecker

```haxe
static function getChecker():Checker
```

Returns the shared `Checker`.

### run

```haxe
static function run(obj:Model<Dynamic>, compName:String, locals:{  }):Void
```

Builds the children of the object by interpreting the markup of its component. Called by the generated `initComponent()`.

### clearCache

```haxe
static function clearCache(name:String):Void
```

Forgets the parsed markup of the component, to load it again.

### init

```haxe
static function init(callb:() -> Dynamic):Bool
```

Watches the source files of the interpreted components: `callb` is called with the class of a component whose markup changed. Returns `true` if a source was found.
