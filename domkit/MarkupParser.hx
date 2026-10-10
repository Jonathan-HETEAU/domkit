package domkit;

using StringTools;

/**
	The states of the markup parser.
**/
enum abstract MToken(Int) {
	/**
		Skipping spaces.
	**/
	var IGNORE_SPACES;
	/**
		Before a node or text.
	**/
	var BEGIN;
	/**
		After `<`.
	**/
	var BEGIN_NODE;
	/**
		After `$` in a text.
	**/
	var BEGIN_CODE;
	/**
		In a `$ident` code.
	**/
	var CODE_IDENT;
	/**
		In a `${ code }` block.
	**/
	var CODE_BLOCK;
	/**
		In a node name.
	**/
	var TAG_NAME;
	/**
		In a node, between its attributes.
	**/
	var BODY;
	/**
		In an attribute name.
	**/
	var ATTRIB_NAME;
	/**
		Expecting `=` after an attribute name.
	**/
	var EQUALS;
	/**
		Before an attribute value.
	**/
	var ATTVAL_BEGIN;
	/**
		In a quoted attribute value.
	**/
	var ATTRIB_VAL;
	/**
		In an attribute value code (`attr={code}`).
	**/
	var ATTRIB_VAL_CODE;
	/**
		In the children of a node.
	**/
	var CHILDS;
	/**
		In a closing node.
	**/
	var CLOSE;
	/**
		Expecting `>` after `/`.
	**/
	var WAIT_END;
	/**
		Expecting `>` at the end of a closing node.
	**/
	var WAIT_END_RET;
	/**
		In a text.
	**/
	var PCDATA;
	/**
		In a `<?` header.
	**/
	var HEADER;
	/**
		In a `<!-- -->` comment.
	**/
	var COMMENT;
	/**
		In a `<!DOCTYPE>`.
	**/
	var DOCTYPE;
	/**
		In a CDATA section.
	**/
	var CDATA;
	/**
		In an `&entity;`.
	**/
	var ESCAPE;
	/**
		In the arguments of a node (`<node(args)>`).
	**/
	var ARGS;
	/**
		In a macro name (`@name`).
	**/
	var MACRO_ID;
	/**
		In a node condition (`<node if(cond)>`).
	**/
	var IF_COND;
	/**
		In the parent component name of a definition (`<name:parent>`).
	**/
	var PARENT_NAME;
	/**
		In the arguments of the parent component.
	**/
	var PARENT_ARGS;
}

/**
	Haxe code in the markup: an expression in macros, the source code otherwise.
**/
typedef CodeExpr = #if macro haxe.macro.Expr #else String #end;

/**
	The kind of a markup node.
**/
enum MarkupKind {
	/**
		A component node (`<name>`), or the root of the document (`null` name).
	**/
	Node( name : String );
	/**
		A text.
	**/
	Text( text : String );
	/**
		Haxe code (`$ident` or `${ code }`), creating children.
	**/
	CodeBlock( v : String );
	/**
		A macro call (`@name(args)`), expanded by `domkit.Macros.processMacro`.
	**/
	Macro( id : String );
	/**
		A loop (`for( x in a ) <node/>`, or with `{ }` for several children).
	**/
	For( cond : CodeExpr );
}

/**
	The value of an attribute or argument.
**/
enum AttributeValue {
	/**
		A string, parsed as CSS (`attr="value"`).
	**/
	RawValue( v : String );
	/**
		Haxe code (`attr={code}`, or `"$code"`).
	**/
	Code( v : CodeExpr );
}

/**
	A node argument (`<node(arg1, arg2)>`), passed to the component constructor.
**/
typedef Argument = {
	/**
		The value.
	**/
	var value : AttributeValue;
	/**
		The start position.
	**/
	var pmin : Int;
	/**
		The end position.
	**/
	var pmax : Int;
};

/**
	A node of the markup tree.
**/
typedef Markup = {
	/**
		The kind of node.
	**/
	var kind : MarkupKind;
	/**
		The start position in the source.
	**/
	var pmin : Int;
	/**
		The end position in the source.
	**/
	var pmax : Int;
	/**
		The arguments (`<node(args)>`).
	**/
	var ?arguments : Array<Argument>;
	/**
		The attributes.
	**/
	var ?attributes : Array<{ name : String, value : AttributeValue, pmin : Int, vmin : Int, pmax : Int }>;
	/**
		The children.
	**/
	var ?children : Array<Markup>;
	/**
		The condition (`<node if(cond)>`): the node is created only if it is true.
	**/
	var ?condition : { cond : CodeExpr, pmin : Int, pmax : Int };
	/**
		The parent component of a component definition (`<name:parent(args)>`).
	**/
	var ?parent : { name : String, pmin : Int, pmax : Int, arguments : Array<Argument> };
}

private typedef MarkupLoop = {
	var obj : Markup;
	var isBlock : Bool;
	var prevLoop : MarkupLoop;
}

/**
	Parses the XML-like markup of the components (`static var SRC = <comp>...</comp>`).
**/
class MarkupParser {

	static var escapes = {
		var h = new haxe.ds.StringMap();
		h.set("lt", "<");
		h.set("gt", ">");
		h.set("amp", "&");
		h.set("quot", '"');
		h.set("apos", "'");
		h;
	}

	var fileName : String;
	var filePos : Int;

	/**
		Accepts the code blocks that are not loops as raw text, instead of failing.
	**/
	public var allowRawText : Bool = false;

	/**
		Creates a parser.
	**/
	public function new() {
	}

	/**
		Parses the markup and returns its root, whose children are the top nodes. `filePos` is added to the positions of the nodes and errors.
	**/
	public function parse(str:String,fileName:String,filePos:Int) {
		var p : Markup = {
			kind : Node(null),
			pmin : 0,
			pmax : 0,
			children : [],
		};
		this.fileName = fileName;
		this.filePos = filePos;
		doParse(str, 0, p);
		return p;
	}

	function error( msg : String, position : Int, pmax = -1 ) : Dynamic {
		throw new Error(msg, filePos + position, pmax < 0 ? -1 : filePos + pmax);
		return null;
	}

	function parseAttr( val : String, start : Int ) {
		var v = StringTools.trim(val);
		if( v.length == 0 || v.charCodeAt(0) != "$".code )
			return RawValue(val);
		if( v.charCodeAt(1) == "{".code && v.charCodeAt(v.length-1) == "}".code )
			v = v.substr(2,v.length - 3);
		else
			v = v.substr(1);
		start += val.indexOf(v);
		return Code(parseCode(v, start));
	}

	function parseCode( v : String, start : Int ) {
		#if macro
		var e = try {
			var pos = haxe.macro.Context.makePosition({ min : filePos + start, max : filePos + start + v.length, file : fileName });
			haxe.macro.Context.parseInlineString(v,pos);
		} catch( e : Dynamic ) {
			// fallback for attr={x:v,y:v}
			try {
				var pos = haxe.macro.Context.makePosition({ min : filePos + start - 1, max : filePos + start + v.length + 1, file : fileName });
				haxe.macro.Context.parseInlineString("{"+v+"}",pos);
			} catch( _ : Dynamic )
				error("" + e, start, start + v.length);
		}
		switch( e.expr ) {
		case EConst(CIdent(i)) if( i.length != v.length ):
			// fallback for https://github.com/HaxeFoundation/haxe/issues/11368
			var e2 = try haxe.macro.Context.parseInlineString("{"+v+"}",haxe.macro.Context.makePosition({ min : filePos + start - 1, max : filePos + start + v.length + 1, file : fileName })) catch( e : Dynamic ) null;
			if( e2 != null && e2.expr.match(EObjectDecl(_)) )
				e = e2;
		default:
		}
		return e;
		#else
		return v;
		#end
	}

	function doParse(str:String, p:Int = 0, ?parent:Markup):Int {
		var obj : Markup = null;
		var state = BEGIN;
		var next = BEGIN;
		var aname = null;
		var start = 0;
		var nsubs = 0;
		var nbrackets = 0;
		var nbraces = 0;
		var nparents = 0;
		var attr_start = 0;
		var prevObj = null;
		var c = str.fastCodeAt(p);
		var buf = new StringBuf();
		// need extra state because next is in use
		var escapeNext = BEGIN;
		var attrValQuote = -1;
		var parentCount = 0;
		var currentLoop : MarkupLoop = null;
		inline function addChild(m:Markup) {
			m.pmin += filePos;
			m.pmax += filePos;
			if( currentLoop != null ) {
				currentLoop.obj.children.push(m);
				if( !currentLoop.isBlock )
					currentLoop = currentLoop.prevLoop;
			} else {
				parent.children.push(m);
				nsubs++;
			}
		}
		var r_prefix = ~/^([a-z]+)/;
		var r_string = ~/^['"]([^'"]*)['"]$/;
		function emitCode() {
			var fullText = buf.toString();
			var text = StringTools.trim(fullText);
			if( text.length == 0 )
				return;
			start += fullText.indexOf(text);
			if( r_prefix.match(text) ) {
				switch( r_prefix.matched(1) ) {
				case "for":
					var cond = r_prefix.matchedRight();
					var isBlock = false;
					if( StringTools.endsWith(cond,"{") ) {
						isBlock = true;
						cond = cond.substr(0,-1);
					}
					var obj = {
						kind : For(parseCode(cond,start+3)),
						pmin : start,
						pmax : start + text.length,
						children : [],
					};
					addChild(obj);
					currentLoop = { prevLoop : currentLoop, isBlock : isBlock, obj : obj };
					return;
				}
			} else if( text == "}" && currentLoop != null && currentLoop.isBlock ) {
				currentLoop = currentLoop.prevLoop;
				return;
			}
			if( !allowRawText ) {
				error("Unsupported code block", start, start + text.length);
				return;
			}
			addChild({
				kind : Text(text),
				pmin : start,
				pmax : start + text.length,
				children : [],
			});
		}
		inline function addNodeArg(last) {
			var base = str.substr(start, p - start);
			var arg = StringTools.trim(base);
			if( arg == "" ) {
				if( !last || obj.arguments.length > 0 )
					error("Empty argument", start, p + 1);
				start = p + 1;
				return;
			}
			start += base.indexOf(arg);
			var a : Argument;
			if( r_string.match(arg) ) {
				a = { value : RawValue(arg.substr(1,arg.length - 2)), pmin : filePos + start + 1, pmax : filePos + start + arg.length - 1 };
			} else {
				a = { value : Code(parseCode(arg,start)), pmin : filePos + start, pmax : filePos + start + arg.length };
			}
			if( state == ARGS )
				obj.arguments.push(a);
			else
				obj.parent.arguments.push(a);
			start = p + 1;
		}
		while (!StringTools.isEof(c)) {
			switch(state) {
				case IGNORE_SPACES:
					switch(c)
					{
						case
							'\n'.code,
							'\r'.code,
							'\t'.code,
							' '.code:
						case '/'.code:
							c = str.fastCodeAt(++p);
							switch( c ) {
							case '/'.code:
								while( true ) {
									c = str.fastCodeAt(++p);
									if( StringTools.isEof(c) || c == '\n'.code )
										break;
								}
								continue;
							case '*'.code:
								var start = p;
								while( true ) {
									c = str.fastCodeAt(++p);
									if( StringTools.isEof(c) )
										error("Unclosed comment", start, start+2);
									if( c == '/'.code && str.fastCodeAt(p-1) == '*'.code )
										break;
								}
							default:
								state = next;
								p--;
								c = '/'.code;
								continue;
							}
						default:
							state = next;
							continue;
					}
				case BEGIN:
					switch(c)
					{
						case '<'.code:
							state = IGNORE_SPACES;
							next = BEGIN_NODE;
						default:
							start = p;
							state = PCDATA;
							continue;
					}
				case PCDATA:
					switch( c ) {
					case '<'.code, '$'.code:
						buf.addSub(str, start, p - start);
						emitCode();
						buf = new StringBuf();
						if( c == '$'.code ) {
							start = p + 1;
							state = BEGIN_CODE;
						} else {
							state = IGNORE_SPACES;
							next = BEGIN_NODE;
						}
					case '@'.code:
						if( StringTools.trim(str.substr(start, p - start)) == "" ) {
							buf.addSub(str, start, p - start);
							state = MACRO_ID;
							start = p + 1;
						}
					case '/'.code, '*'.code:
						if( p > start && str.charCodeAt(p-1) == '/'.code ) {
							buf.addSub(str, start, p - 1 - start);
							if( c == '/'.code ) {
								while( true ) {
									c = str.fastCodeAt(p++);
									if( StringTools.isEof(c) || c == '\n'.code ) break;
								}
								start = p;
							} else {
								start = p - 1;
								var end = false;
								while( true ) {
									c = str.fastCodeAt(p++);
									if( StringTools.isEof(c) ) error("Unclosed comment", start, start + 2);
									if( c == '*'.code ) end = true else if( end && c == '/'.code ) break; else end = false;
								}
								start = p;
							}
						}
					}
				case MACRO_ID:
					if( !isValidChar(c) ) {
						var id = str.substr(start, p - start);
						var m : Markup = {
							kind : Macro(id),
							pmin : start,
							pmax : p,
						};
						addChild(m);
						if( c == '('.code ) {
							state = ARGS;
							prevObj = obj;
							obj = m;
							obj.arguments = [];
							start = p + 1;
							nparents = 1;
							nbrackets = nbraces = 0;
						} else {
							start = p;
							state = PCDATA;
							buf = new StringBuf();
							continue;
						}
					}
				case CDATA:
					if (c == ']'.code && str.fastCodeAt(p + 1) == ']'.code && str.fastCodeAt(p + 2) == '>'.code)
					{
						var child : Markup = {
							kind : Text(str.substr(start, p - start)),
							pmin : start,
							pmax : p,
						};
						addChild(child);
						p += 2;
						state = BEGIN;
					}
				case BEGIN_NODE:
					switch(c)
					{
						case '!'.code:
							if (str.fastCodeAt(p + 1) == '['.code)
							{
								p += 2;
								if (str.substr(p, 6).toUpperCase() != "CDATA[")
									error("Expected <![CDATA[", p);
								p += 5;
								state = CDATA;
								start = p + 1;
							}
							else if (str.fastCodeAt(p + 1) == 'D'.code || str.fastCodeAt(p + 1) == 'd'.code)
							{
								if(str.substr(p + 2, 6).toUpperCase() != "OCTYPE")
									error("Expected <!DOCTYPE", p);
								p += 8;
								state = DOCTYPE;
								start = p + 1;
							}
							else if( str.fastCodeAt(p + 1) != '-'.code || str.fastCodeAt(p + 2) != '-'.code )
								error("Expected <!--", p);
							else
							{
								p += 2;
								state = COMMENT;
								start = p + 1;
							}
						case '?'.code:
							state = HEADER;
							start = p;
						case '/'.code:
							if( parent == null )
								error("Expected node name", p);
							start = p + 1;
							state = IGNORE_SPACES;
							next = CLOSE;
						default:
							state = TAG_NAME;
							start = p;
							continue;
					}
				case BEGIN_CODE:
					if( c == '{'.code ) {
						state = CODE_BLOCK;
						start = p + 1;
						nbraces = 1;
					} else if( !isValidChar(c) ) {
						error("Expected code identifier or block",p);
					} else {
						state = CODE_IDENT;
					}
				case CODE_BLOCK:
					if( c == '{'.code )
						nbraces++;
					else if( c == '}'.code ) {
						nbraces--;
						if( nbraces == 0 ) {
							addChild({
								kind : CodeBlock(str.substr(start,p - start)),
								pmin : start,
								pmax : p,
							});
							state = BEGIN;
						}
					}
				case CODE_IDENT:
					if (!isValidChar(c)) {
						addChild({
							kind : CodeBlock(str.substr(start,p - start)),
							pmin : start,
							pmax : p,
						});
						state = BEGIN;
						continue;
					}
				case TAG_NAME:
					if (!isValidChar(c)) {
						if( p == start )
							error("Expected node name", p);
						obj = {
							kind : Node(str.substr(start, p - start)),
							pmin : start,
							pmax : p,
							arguments : [],
							attributes : [],
							children : [],
						};
						addChild(obj);
						if( c == '('.code ) {
							state = ARGS;
							next = BODY;
							start = p + 1;
							nparents = 1;
							nbrackets = nbraces = 0;
						} else {
							state = IGNORE_SPACES;
							next = BODY;
							continue;
						}
					}
				case BODY:
					switch( c ) {
					case ':'.code:
						var plast = obj.arguments != null && obj.arguments.length > 0 ? obj.arguments[obj.arguments.length - 1].pmax + 1 : obj.pmax;
						if( parent != null && !parent.kind.equals(Node(null)) )
							error("Invalid parent declaration", p);
						if( p != plast - filePos )
							error("Invalid character :", p);
						state = PARENT_NAME;
						start = p + 1;
					case '/'.code:
						state = WAIT_END;
					case '>'.code:
						state = CHILDS;
					default:
						state = ATTRIB_NAME;
						start = p;
						continue;
					}
				case PARENT_NAME:
					if (!isValidChar(c)) {
						var tmp;
						if( start == p )
							error("Expected node name", p);
						var parentName = str.substr(start,p-start);
						obj.parent = {
							name : parentName,
							pmin : start,
							pmax : p,
							arguments : [],
						};
						if( c == '('.code ) {
							state = PARENT_ARGS;
							next = BODY;
							start = p + 1;
							nparents = 1;
							nbrackets = nbraces = 0;
						} else {
							state = BODY;
							continue;
						}
					}
				case ATTRIB_NAME:
					if (!isValidChar(c)) {
						var tmp;
						if( start == p )
							error("Expected attribute name", p);
						tmp = str.substr(start,p-start);
						aname = tmp;
						for( a in obj.attributes )
							if( a.name == aname )
								error("Duplicate attribute '" + aname + "'", p);
						attr_start = start;
						state = IGNORE_SPACES;
						next = aname == "if" ? IF_COND : EQUALS;
						continue;
					}
				case EQUALS:
					switch(c) {
						case '='.code:
							state = IGNORE_SPACES;
							next = ATTVAL_BEGIN;
						case ' '.code, '\n'.code, '\t'.code, '\r'.code, '>'.code, '/'.code:
							obj.attributes.push({ name : aname, value : RawValue("true"), pmin : attr_start + filePos, vmin : attr_start + filePos, pmax : p + filePos });
							state = IGNORE_SPACES;
							next = BODY;
							continue;
						default:
							if( isValidChar(c) ) {
								obj.attributes.push({ name : aname, value : RawValue("true"), pmin : attr_start + filePos, vmin : attr_start + filePos, pmax : p + filePos });
								state = BODY;
								continue;
							}
							error("Expected =", p);
					}
				case IF_COND:
					switch( c ) {
					case '('.code:
						parentCount++;
					case ')'.code:
						parentCount--;
						if( parentCount == 0 ) {
							var code = str.substr(start + 2, p - start - 1);
							if( obj.condition != null ) error("Duplicate condition", start);
							obj.condition = { cond : parseCode(code, start+2), pmin : start + filePos + 2, pmax : p + filePos + 1 };
							state = BODY;
						}
					default:
					}
				case ATTVAL_BEGIN:
					switch(c)
					{
						case '"'.code | '\''.code:
							buf = new StringBuf();
							state = ATTRIB_VAL;
							start = p + 1;
							attrValQuote = c;
						case '{'.code:
							state = ATTRIB_VAL_CODE;
							start = p + 1;
							nbraces = 1;
						default:
							error("Expected \"", p);
					}
				case ATTRIB_VAL:
					switch (c) {
						case '&'.code:
							buf.addSub(str, start, p - start);
							state = ESCAPE;
							escapeNext = ATTRIB_VAL;
							start = p + 1;
						case '>'.code | '<'.code:
							// HTML allows these in attributes values
							error("Invalid unescaped " + String.fromCharCode(c) + " in attribute value", p);
						case _ if (c == attrValQuote):
							buf.addSub(str, start, p - start);
							var val = buf.toString();
							buf = new StringBuf();
							obj.attributes.push({ name : aname, value : parseAttr(val,start), pmin : attr_start + filePos, vmin : start + filePos, pmax : p + filePos });
							state = IGNORE_SPACES;
							next = BODY;
					}
				case ATTRIB_VAL_CODE:
					switch( c ) {
					case '{'.code:
						nbraces++;
					case '}'.code:
						nbraces--;
						if( nbraces == 0 ) {
							obj.attributes.push({ name : aname, value : Code(parseCode(str.substr(start, p-start),start)), pmin : attr_start + filePos, vmin : start + filePos, pmax : p + filePos });
							state = IGNORE_SPACES;
							next = BODY;
						}
					}
				case ARGS, PARENT_ARGS:
					switch( c ) {
					case ")".code:
						nparents--;
						if( nparents == 0 ) {
							addNodeArg(true);
							state = next;
							if( state == BODY ) {
								state = IGNORE_SPACES;
								next = BODY;
							} else
								obj = prevObj;
						}
					case '('.code:
						nparents++;
					case '{'.code:
						nbraces++;
					case '['.code:
						nbrackets++;
					case '}'.code:
						nbraces--;
					case ']'.code:
						nbrackets--;
					case ','.code if( nparents == 1 && nbrackets == 0 && nbraces == 0 ):
						addNodeArg(false);
					}
				case CHILDS:
					p = doParse(str, p, obj);
					start = p;
					state = BEGIN;
				case WAIT_END:
					switch(c)
					{
						case '>'.code:
							state = BEGIN;
						default :
							error("Expected >", p);
					}
				case WAIT_END_RET:
					switch(c)
					{
						case '>'.code:
							if( currentLoop != null )
								error("Unclosed loop", currentLoop.obj.pmin - filePos, currentLoop.obj.pmax - filePos);
							return p;
						default :
							error("Expected >", p);
					}
				case CLOSE:
					if (!isValidChar(c))
					{
						if( start == p )
							error("Expected node name", p);

						var v = str.substr(start,p - start);
						var ok = true;
						if( parent == null )
							ok = false;
						else switch( parent.kind ) {
						case Node(name) if( name != null && v == name.split(":")[0] ): // ok
						case Node(name) if( name != null ):
							error("Unclosed node <" + name.split(":")[0] + ">", parent.pmin - filePos, parent.pmax - filePos);
						default:
							ok = false;
						}
						if( !ok )
							error('Unexpected </$v>', p);
						state = IGNORE_SPACES;
						next = WAIT_END_RET;
						continue;
					}
				case COMMENT:
					if (c == '-'.code && str.fastCodeAt(p +1) == '-'.code && str.fastCodeAt(p + 2) == '>'.code)
					{
						//addChild(Xml.createComment(str.substr(start, p - start)));
						p += 2;
						state = BEGIN;
					}
				case DOCTYPE:
					if(c == '['.code)
						nbrackets++;
					else if(c == ']'.code)
						nbrackets--;
					else if (c == '>'.code && nbrackets == 0)
					{
						//addChild(Xml.createDocType(str.substr(start, p - start)));
						state = BEGIN;
					}
				case HEADER:
					if (c == '?'.code && str.fastCodeAt(p + 1) == '>'.code)
					{
						p++;
						var str = str.substr(start + 1, p - start - 2);
						//addChild(Xml.createProcessingInstruction(str));
						state = BEGIN;
					}
				case ESCAPE:
					if (c == ';'.code)
					{
						var s = str.substr(start, p - start);
						if (s.fastCodeAt(0) == '#'.code) {
							var c = s.fastCodeAt(1) == 'x'.code
								? Std.parseInt("0" +s.substr(1, s.length - 1))
								: Std.parseInt(s.substr(1, s.length - 1));
							buf.addChar(c);
						} else if (!escapes.exists(s)) {
							error("Undefined entity: " + s, p);
							buf.add('&$s;');
						} else {
							buf.add(escapes.get(s));
						}
						start = p + 1;
						state = escapeNext;
					} else if (!isValidChar(c) && c != "#".code) {
						error("Invalid character in entity: " + String.fromCharCode(c), p);
						buf.addChar("&".code);
						buf.addSub(str, start, p - start);
						p--;
						start = p + 1;
						state = escapeNext;
					}
			}
			c = str.fastCodeAt(++p);
		}

		if (state == BEGIN)
		{
			start = p;
			state = PCDATA;
		}

		if (state == PCDATA)
		{
			switch( parent.kind ) {
			case Node(name) if( name != null ):
				error("Unclosed node <" + name + ">", p);
			default:
			}
			if (p != start || nsubs == 0) {
				buf.addSub(str, start, p-start);
				emitCode();
			}
			if( currentLoop != null )
				error("Unclosed loop", currentLoop.obj.pmin - filePos);
			return p;
		}

		error("Unexpected end", p);
		return p;
	}

	static inline function isValidChar(c) {
		return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code) || c == '.'.code || c == '_'.code || c == '-'.code;
	}

	static function codeToString( v : CodeExpr ) : String {
		#if macro
		return haxe.macro.ExprTools.toString(v);
		#else
		return v;
		#end
	}

	/**
		Returns the markup source of a node.
	**/
	public static function markupToString( m : Markup ) {
		var buf = new StringBuf();
		markupToStringRec(m, buf, "");
		return buf.toString();
	}

	static function markupToStringRec( m : Markup, buf : StringBuf, tabs : String ) {
		if( buf == null ) buf = new StringBuf();
		switch( m.kind ) {
		case Node(null):
			var first = true;
			for( c in m.children ) {
				if( first ) first = false else buf.add('\n\n');
				markupToStringRec(c,buf,tabs);
			}
		case Node(name):
			buf.add('<');
			buf.add(name);
			inline function addArgs( args : Array<Argument> ) {
				if( args != null && args.length > 0 ) {
					buf.add('(');
					var first = true;
					for( a in args ) {
						if( first ) first = false else buf.add(',');
						switch( a.value ) {
						case RawValue(v): buf.add('"$v"');
						case Code(v): buf.add(codeToString(v));
						}
					}
					buf.add(')');
				}
			}
			addArgs(m.arguments);
			if( m.parent != null ) {
				buf.add(':');
				buf.add(m.parent.name);
				addArgs(m.parent.arguments);
			}
			if( m.attributes != null ) {
				for( a in m.attributes ) {
					buf.add(' ');
					buf.add(a.name);
					if( a.value.equals(RawValue("true")) )
						continue;
					buf.add('=');
					switch( a.value ) {
					case RawValue(v): buf.add('"$v"');
					case Code(v): buf.add('{${codeToString(v)}}');
					}
				}
			}
			if( m.condition != null ) {
				buf.add(' if');
				buf.add(codeToString(m.condition.cond));
			}
			if( m.children != null && m.children.length > 0 ) {
				buf.add('>\n');
				var prev = tabs;
				tabs += "\t";
				for( c in m.children ) {
					buf.add(tabs);
					markupToStringRec(c, buf, tabs);
					buf.add('\n');
				}
				var part = name.split(":")[0];
				buf.add('$prev</$part>');
			} else {
				buf.add('/>');
			}
		case Text(text):
			buf.add(StringTools.htmlEscape(text));
		case CodeBlock(v):
			buf.add(v);
		case Macro(id):
			buf.add('@$id');
			if( m.arguments != null ) {
				buf.add('(');
				var first = true;
				for( a in m.arguments ) {
					if( first ) first = false else buf.add(',');
					switch( a.value ) {
					case RawValue(v): buf.add('"$v"');
					case Code(v): buf.add(codeToString(v));
					}
				}
				buf.add(')');
			}
		case For(cond):
			buf.add('for');
			buf.add(codeToString(cond));
			tabs += "\t";
			for( c in m.children ) {
				buf.add("\n"+tabs);
				markupToStringRec(c, buf, tabs);
			}
		}
	}

}
