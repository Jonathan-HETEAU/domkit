# Package `domkit`

[← API index](../README.md)

| Type | Kind | Summary |
|---|---|---|
| [`Argument`](Argument.md) | typedef | A node argument (`<node(arg1, arg2)>`), passed to the component constructor. |
| [`AttributeValue`](AttributeValue.md) | enum | The value of an attribute or argument. |
| [`BezierCurve`](BezierCurve.md) | class | A cubic bezier easing curve, like CSS `cubic-bezier(c1x, c1y, c2x, c2y)`. |
| [`BytesCell`](BytesCell.md) | class | An entry of a `BytesMap`. |
| [`BytesMap`](BytesMap.md) | abstract | A map with bytes keys, used by the style cache on HashLink. |
| [`Checker`](Checker.md) | class | Type checks the markup and the CSS of components at runtime (for the interpreted components of `Interp`, or in editors such as Hide), from the types of the Heaps components (`h2d.domkit.InitComponents.build()` classes). |
| [`CodeExpr`](CodeExpr.md) | typedef | Haxe code in the markup: an expression in macros, the source code otherwise. |
| [`Component`](Component.md) | class | A component: the name used in the markup and in CSS (`button`, `flow`...), how to create its objects of type `T`, and how it handles the CSS properties. |
| [`ComponentDecl`](ComponentDecl.md) | interface | Declares the component of another class `T`: a class implementing `ComponentDecl<T>` (with `domkit.Object`) defines the properties of `T`, for classes that can't be modified. |
| [`CssClass`](CssClass.md) | class | A CSS selector part: component, class names, id and pseudo classes, with its parent selector. |
| [`CssData`](CssData.md) | class | The rules of a `CssStyle`, sorted by priority, and the cache of the rules matching a set of components. |
| [`CssOp`](CssOp.md) | enum | An arithmetic operator in a CSS value. |
| [`CssParser`](CssParser.md) | class | Parses CSS style sheets and values, with the DomKit extensions: nested rules (`&`, `>`), variables (`@name : value;`), mixins (`.name(args) { }` used as `.name(values);`), arithmetic, and `//` comments. |
| [`CssRelation`](CssRelation.md) | enum abstract | The relation between a selector and its parent selector. |
| [`CssRule`](CssRule.md) | typedef | A property set by a CSS rule, with its position in the source. |
| [`CssSheet`](CssSheet.md) | typedef | A parsed style sheet. |
| [`CssSheetElement`](CssSheetElement.md) | typedef | A CSS rule: its selectors, properties, transitions and nested rules. |
| [`CssStyle`](CssStyle.md) | class | A style: CSS rules applied to objects with `Properties.applyStyle`, and the running transitions, updated with `updateTime`. |
| [`CssTransition`](CssTransition.md) | class | A running transition of a property of an object. |
| [`CssValue`](CssValue.md) | enum | A parsed CSS value. |
| [`Curve`](Curve.md) | class | An easing curve: linear. |
| [`DMLChecker`](DMLChecker.md) | class | Parses and type checks the markup of a component (DML), and checks CSS rules against the components. |
| [`Error`](Error.md) | class | An error while parsing markup or CSS, with its position in the source. |
| [`FastBytes`](FastBytes.md) | typedef | Bytes used for the component bit sets of the style cache: `hl.Bytes` on HashLink, `haxe.io.Bytes` elsewhere. |
| [`HSL`](HSL.md) | class | A color in the HSL color space, used by the `darken`, `lighten`, `saturate` and `desaturate` color functions. |
| [`Identifier`](Identifier.md) | abstract | A string (class name or id) converted to a unique integer, for fast comparisons. |
| [`Interp`](Interp.md) | class | Runs the markup of components with hscript instead of compiled code, to reload it while the program runs (hot reload). |
| [`InvalidProperty`](InvalidProperty.md) | class | Thrown by a property parser when the CSS value is invalid. |
| [`MToken`](MToken.md) | enum abstract | The states of the markup parser. |
| [`Macros`](Macros.md) | class | The macros of DomKit: build the `domkit.Object` classes (`buildObject`), and the configuration functions to call from an initialization macro (`--macro`). |
| [`Markup`](Markup.md) | typedef | A node of the markup tree. |
| [`MarkupKind`](MarkupKind.md) | enum | The kind of a markup node. |
| [`MarkupParser`](MarkupParser.md) | class | Parses the XML-like markup of the components (`static var SRC = <comp>...</comp>`). |
| [`MetaComponent`](MetaComponent.md) | class | The component of a `domkit.Object` class at compile time: reads its `@:p` properties and constructor, and generates its runtime `Component`. |
| [`MetaError`](MetaError.md) | class | An error of the component macros. |
| [`Model`](Model.md) | interface | The base type of the objects of the UI, `T` being the base class of the components: implement it on your base class (with Heaps, `h2d.Object` is used). |
| [`Object`](Object.md) | interface | A class whose instances are built by DomKit: its `@:p` fields become CSS properties of its component, and its `static var SRC = <comp>...</comp>` markup is compiled into an `initComponent()` method creating the childr... |
| [`ParserMode`](ParserMode.md) | enum | How the value of a `@:p` property is parsed. |
| [`PropParser`](PropParser.md) | enum | How a property value is parsed, for the type checking of CSS values. |
| [`Properties`](Properties.md) | class | The DomKit state of an object (its `dom` field): component, id, classes, pseudo class states (`hover`, `active`...) and the CSS values set on it. |
| [`Property`](Property.md) | class | A CSS property name, registered once with a unique id (see `get`). |
| [`PropertyHandler`](PropertyHandler.md) | class | How a component handles a CSS property: parses its value, applies it to the objects of type `O`, and interpolates it for the transitions. |
| [`PseudoClass`](PseudoClass.md) | enum abstract | The pseudo classes of a CSS selector, as bit flags. |
| [`Rule`](Rule.md) | class | A CSS rule for one selector, with its priority. |
| [`RuleStyle`](RuleStyle.md) | class | A property set by a `Rule`. |
| [`RuleTransition`](RuleTransition.md) | class | A transition set by a `Rule`. |
| [`ScriptInterp`](ScriptInterp.md) | class | The hscript interpreter running the code of an interpreted component. |
| [`SetAttributeResult`](SetAttributeResult.md) | enum | The result of `Properties.setAttribute`. |
| [`Token`](Token.md) | enum | A token of the CSS lexer. |
| [`Transition`](Transition.md) | typedef | A transition of a property, declared with the `transition` CSS property. |
| [`TypedComponent`](TypedComponent.md) | typedef | A component, with the types of its class, properties and constructor arguments. |
| [`TypedProperty`](TypedProperty.md) | typedef | A property of a component, with its type. |
| [`ValueParser`](ValueParser.md) | class | Converts CSS values to property values: the `parseXxx` methods are used by the `@:p(xxx)` fields (`@:p(color)` uses `parseColor`). |
