# domkit.Macros

**class** · package [`domkit`](README.md) · source [`domkit/Macros.hx`](../../../../domkit/Macros.hx)

The macros of DomKit: build the `domkit.Object` classes (`buildObject`), and the configuration functions to call from an initialization macro (`--macro`).

## Static methods

### generateRemapMap

```haxe
static function generateRemapMap():Dynamic
```

Returns the component remaps (see `registerComponentRemap`), for the runtime.

### generateLocalsObj

```haxe
static function generateLocalsObj():Dynamic
```

Returns the local variables, with their values and types, for the interpreted components (with hscript).

### generateLocalsTypes

```haxe
static function generateLocalsTypes():Dynamic
```

Returns the local variables as an object (with hscript).

### generateLocalsRestore

```haxe
static function generateLocalsRestore():Dynamic
```

Sets back the local variables from `__locals`, after the interpreted markup (with hscript).
