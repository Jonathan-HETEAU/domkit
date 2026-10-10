# domkit.Error

**class** · package [`domkit`](README.md) · source [`domkit/Error.hx`](../../../../domkit/Error.hx)

An error while parsing markup or CSS, with its position in the source.

## Constructor

### new

```haxe
function new(messsage:String, ?pmin:Int = -1, ?pmax:Int = -1):Void
```

Creates the error. `pmax` defaults to `pmin + 1`.

## Variables

### message

```haxe
var message:String
```

The error message.

### pmin

```haxe
var pmin:Int
```

The start position in the source, or `-1`.

### pmax

```haxe
var pmax:Int
```

The end position in the source.

## Methods

### toString

```haxe
function toString():String
```

Returns a description of the error.
