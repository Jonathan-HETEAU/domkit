# domkit.MToken

**enum abstract** · package [`domkit`](README.md) · module `domkit.MarkupParser` · source [`domkit/MarkupParser.hx`](../../../../domkit/MarkupParser.hx)

The states of the markup parser.

Underlying type: `Int`

## Values

| Name | Value | Description |
|---|---|---|
| `IGNORE_SPACES` | `0` | Skipping spaces. |
| `BEGIN` | `1` | Before a node or text. |
| `BEGIN_NODE` | `2` | After `<`. |
| `BEGIN_CODE` | `3` | After `$` in a text. |
| `CODE_IDENT` | `4` | In a `$ident` code. |
| `CODE_BLOCK` | `5` | In a `${ code }` block. |
| `TAG_NAME` | `6` | In a node name. |
| `BODY` | `7` | In a node, between its attributes. |
| `ATTRIB_NAME` | `8` | In an attribute name. |
| `EQUALS` | `9` | Expecting `=` after an attribute name. |
| `ATTVAL_BEGIN` | `10` | Before an attribute value. |
| `ATTRIB_VAL` | `11` | In a quoted attribute value. |
| `ATTRIB_VAL_CODE` | `12` | In an attribute value code (`attr={code}`). |
| `CHILDS` | `13` | In the children of a node. |
| `CLOSE` | `14` | In a closing node. |
| `WAIT_END` | `15` | Expecting `>` after `/`. |
| `WAIT_END_RET` | `16` | Expecting `>` at the end of a closing node. |
| `PCDATA` | `17` | In a text. |
| `HEADER` | `18` | In a `<?` header. |
| `COMMENT` | `19` | In a `<!-- -->` comment. |
| `DOCTYPE` | `20` | In a `<!DOCTYPE>`. |
| `CDATA` | `21` | In a CDATA section. |
| `ESCAPE` | `22` | In an `&entity;`. |
| `ARGS` | `23` | In the arguments of a node (`<node(args)>`). |
| `MACRO_ID` | `24` | In a macro name (`@name`). |
| `IF_COND` | `25` | In a node condition (`<node if(cond)>`). |
| `PARENT_NAME` | `26` | In the parent component name of a definition (`<name:parent>`). |
| `PARENT_ARGS` | `27` | In the arguments of the parent component. |
