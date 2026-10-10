# domkit.Object

**interface** · package [`domkit`](README.md) · source [`domkit/Object.hx`](../../../../domkit/Object.hx)

A class whose instances are built by DomKit: its `@:p` fields become CSS properties of its component, and its `static var SRC = <comp>...</comp>` markup is compiled into an `initComponent()` method creating the children.

The component name is the class name in CSS casing (`MyButton` is `my-button`), or set with `@:uiComp("name")`; `@:uiNoComponent` builds the markup without declaring a component. The parser of the properties is set with `@:parser(path)` (see `domkit.Macros.setDefaultParser`).
