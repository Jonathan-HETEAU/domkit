# DomKit — carte des dépendances

> Généré par `tools/docgen/deps.py` (analyse statique, sans compilateur Haxe). Ne pas éditer à la main.

- Modules (fichiers `.hx`) : **15** — lignes : **7868** — packages : **1**
- Dépendances module→module : **60**
- Cycles de modules (SCC > 1) : **1**

Légende des types d'arêtes : `import`, `using`, `extends`, `implements`, `use` (référence dans le code).

## Packages

| Package | Modules | Lignes | Blocs doc `/** */` | Dépend de (packages) | Utilisé par |
|---|---:|---:|---:|---|---|
| [`domkit`](modules/domkit.md) | 15 | 7868 | 417 | — | 0 |

## Graphe des packages (niveau 2)

```mermaid
flowchart LR
```

## Cycles entre packages

Aucun.

## Ordre de documentation suggéré

Ordre topologique (les dépendances d'abord). Les modules entre crochets forment un cycle et doivent être documentés ensemble.

1. [`domkit.Error`](modules/domkit.md#domkiterror)
2. [`domkit.Identifier`](modules/domkit.md#domkitidentifier)
3. [`domkit.MarkupParser`](modules/domkit.md#domkitmarkupparser)
4. [[`domkit.Checker`](modules/domkit.md#domkitchecker), [`domkit.Component`](modules/domkit.md#domkitcomponent), [`domkit.CssParser`](modules/domkit.md#domkitcssparser), [`domkit.CssStyle`](modules/domkit.md#domkitcssstyle), [`domkit.CssValue`](modules/domkit.md#domkitcssvalue), [`domkit.Interp`](modules/domkit.md#domkitinterp), [`domkit.Macros`](modules/domkit.md#domkitmacros), [`domkit.MetaComponent`](modules/domkit.md#domkitmetacomponent), [`domkit.Model`](modules/domkit.md#domkitmodel), [`domkit.Properties`](modules/domkit.md#domkitproperties), [`domkit.Property`](modules/domkit.md#domkitproperty)]
5. [`domkit.Object`](modules/domkit.md#domkitobject)

## Modules les plus centraux (les plus utilisés)

| Module | Utilisé par | Dépend de | Lignes |
|---|---:|---:|---:|
| [`domkit.Property`](modules/domkit.md#domkitproperty) | 9 | 1 | 68 |
| [`domkit.Component`](modules/domkit.md#domkitcomponent) | 7 | 6 | 190 |
| [`domkit.CssParser`](modules/domkit.md#domkitcssparser) | 7 | 6 | 1753 |
| [`domkit.Error`](modules/domkit.md#domkiterror) | 7 | 0 | 43 |
| [`domkit.CssValue`](modules/domkit.md#domkitcssvalue) | 6 | 2 | 501 |
| [`domkit.Properties`](modules/domkit.md#domkitproperties) | 5 | 7 | 553 |
| [`domkit.Macros`](modules/domkit.md#domkitmacros) | 4 | 8 | 844 |
| [`domkit.MarkupParser`](modules/domkit.md#domkitmarkupparser) | 4 | 1 | 1041 |
| [`domkit.Identifier`](modules/domkit.md#domkitidentifier) | 3 | 0 | 33 |
| [`domkit.Model`](modules/domkit.md#domkitmodel) | 3 | 1 | 31 |
| [`domkit.CssStyle`](modules/domkit.md#domkitcssstyle) | 2 | 7 | 915 |
| [`domkit.Checker`](modules/domkit.md#domkitchecker) | 1 | 6 | 754 |
| [`domkit.Interp`](modules/domkit.md#domkitinterp) | 1 | 8 | 415 |
| [`domkit.MetaComponent`](modules/domkit.md#domkitmetacomponent) | 1 | 6 | 716 |
| [`domkit.Object`](modules/domkit.md#domkitobject) | 0 | 1 | 11 |
