# Package `domkit`

[← retour](../DEPENDENCIES.md)

## domkit.Checker

- Fichier : `domkit/Checker.hx` — 754 lignes — 36 blocs doc — contient du `#if`
- Types : `enum PropParser`, `typedef TypedProperty`, `typedef TypedComponent`, `class Checker`, `class DMLChecker`
- Héritage : `Checker` extends `hscript.Checker`
- Dépend de : `domkit.Component`, `domkit.CssParser`, `domkit.CssValue`, `domkit.Error`, `domkit.MarkupParser` (import/use), `domkit.Property`
- Utilisé par : `domkit.Interp`

## domkit.Component

- Fichier : `domkit/Component.hx` — 190 lignes — 18 blocs doc — contient du `#if`
- Types : `class PropertyHandler`, `interface ComponentDecl`, `class Component`
- Dépend de : `domkit.CssValue`, `domkit.Error`, `domkit.Macros`, `domkit.MarkupParser`, `domkit.Properties`, `domkit.Property` (import/use)
- Utilisé par : `domkit.Checker`, `domkit.CssParser`, `domkit.CssStyle`, `domkit.Interp`, `domkit.Macros`, `domkit.MetaComponent`, `domkit.Properties`

## domkit.CssParser

- Fichier : `domkit/CssParser.hx` — 1753 lignes — 104 blocs doc — contient du `#if`
- Types : `enum Token`, `enum_abstract PseudoClass`, `enum_abstract CssRelation`, `class CssClass`, `typedef Transition`, `typedef CssSheet`, `typedef CssRule`, `typedef CssSheetElement`, `class Curve`, `class BezierCurve`, `class CssParser`
- Héritage : `BezierCurve` extends `Curve`
- Dépend de : `domkit.Component`, `domkit.CssValue` (import/use), `domkit.Error`, `domkit.Identifier`, `domkit.Macros`, `domkit.Property`
- Utilisé par : `domkit.Checker`, `domkit.CssStyle`, `domkit.CssValue`, `domkit.Interp`, `domkit.Macros`, `domkit.MetaComponent`, `domkit.Properties`

## domkit.CssStyle

- Fichier : `domkit/CssStyle.hx` — 915 lignes — 66 blocs doc — contient du `#if`
- Types : `class RuleStyle`, `class RuleTransition`, `class Rule`, `class CssTransition`, `abstract FastBytes`, `class BytesCell`, `abstract BytesMap`, `typedef FastBytes`, `class CssData`, `class CssStyle`
- Dépend de : `domkit.Component`, `domkit.CssParser`, `domkit.CssValue`, `domkit.Identifier`, `domkit.Model`, `domkit.Properties`, `domkit.Property`
- Utilisé par : `domkit.Properties`, `domkit.Property`

## domkit.CssValue

- Fichier : `domkit/CssValue.hx` — 501 lignes — 48 blocs doc
- Types : `enum CssOp`, `enum CssValue`, `class HSL`, `class ValueParser`
- Dépend de : `domkit.CssParser`, `domkit.Property` (import/use)
- Utilisé par : `domkit.Checker`, `domkit.Component`, `domkit.CssParser`, `domkit.CssStyle`, `domkit.MetaComponent`, `domkit.Properties`

## domkit.Error

- Fichier : `domkit/Error.hx` — 43 lignes — 6 blocs doc
- Types : `class Error`
- Utilisé par : `domkit.Checker`, `domkit.Component`, `domkit.CssParser`, `domkit.Interp`, `domkit.Macros`, `domkit.MarkupParser`, `domkit.MetaComponent`

## domkit.Identifier

- Fichier : `domkit/Identifier.hx` — 33 lignes — 4 blocs doc — contient du `#if`
- Types : `abstract Identifier`
- Utilisé par : `domkit.CssParser`, `domkit.CssStyle`, `domkit.Properties`

## domkit.Interp

- Fichier : `domkit/Interp.hx` — 415 lignes — 10 blocs doc — contient du `#if`
- Types : `class ScriptInterp`, `class Interp`
- Héritage : `ScriptInterp` extends `hscript.Interp`
- Dépend de : `domkit.Checker`, `domkit.Component`, `domkit.CssParser`, `domkit.Error`, `domkit.MarkupParser` (import/use), `domkit.Model`, `domkit.Properties`, `domkit.Property`
- Utilisé par : `domkit.Macros`

## domkit.Macros

- Fichier : `domkit/Macros.hx` — 844 lignes — 13 blocs doc — contient du `#if`
- Types : `typedef ComponentData`, `class Macros`
- Dépend de : `domkit.Component`, `domkit.CssParser`, `domkit.Error` (import/use), `domkit.Interp`, `domkit.MarkupParser`, `domkit.MetaComponent`, `domkit.Properties`, `domkit.Property`
- Utilisé par : `domkit.Component`, `domkit.CssParser`, `domkit.MetaComponent`, `domkit.Object`

## domkit.MarkupParser

- Fichier : `domkit/MarkupParser.hx` — 1041 lignes — 57 blocs doc — contient du `#if`
- Types : `enum_abstract MToken`, `typedef CodeExpr`, `enum MarkupKind`, `enum AttributeValue`, `typedef Argument`, `typedef Markup`, `typedef MarkupLoop`, `class MarkupParser`
- Dépend de : `domkit.Error`
- Utilisé par : `domkit.Checker`, `domkit.Component`, `domkit.Interp`, `domkit.Macros`

## domkit.MetaComponent

- Fichier : `domkit/MetaComponent.hx` — 716 lignes — 9 blocs doc — contient du `#if`
- Types : `class MetaError`, `enum ParserMode`, `class MetaComponent`
- Héritage : `MetaComponent` extends `Component`
- Dépend de : `domkit.Component` (extends/use), `domkit.CssParser`, `domkit.CssValue`, `domkit.Error`, `domkit.Macros`, `domkit.Property`
- Utilisé par : `domkit.Macros`

## domkit.Model

- Fichier : `domkit/Model.hx` — 31 lignes — 6 blocs doc — contient du `#if`
- Types : `typedef Model`, `interface Model`
- Dépend de : `domkit.Properties`
- Utilisé par : `domkit.CssStyle`, `domkit.Interp`, `domkit.Properties`

## domkit.Object

- Fichier : `domkit/Object.hx` — 11 lignes — 1 blocs doc
- Types : `interface Object`
- Dépend de : `domkit.Macros`

## domkit.Properties

- Fichier : `domkit/Properties.hx` — 553 lignes — 30 blocs doc — contient du `#if`
- Types : `enum SetAttributeResult`, `class DirtyList`, `class Properties`
- Dépend de : `domkit.Component`, `domkit.CssParser`, `domkit.CssStyle`, `domkit.CssValue`, `domkit.Identifier`, `domkit.Model`, `domkit.Property`
- Utilisé par : `domkit.Component`, `domkit.CssStyle`, `domkit.Interp`, `domkit.Macros`, `domkit.Model`

## domkit.Property

- Fichier : `domkit/Property.hx` — 68 lignes — 9 blocs doc
- Types : `class InvalidProperty`, `class Property`
- Dépend de : `domkit.CssStyle`
- Utilisé par : `domkit.Checker`, `domkit.Component`, `domkit.CssParser`, `domkit.CssStyle`, `domkit.CssValue`, `domkit.Interp`, `domkit.Macros`, `domkit.MetaComponent`, `domkit.Properties`
