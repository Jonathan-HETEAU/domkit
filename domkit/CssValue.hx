package domkit;
import domkit.Property.InvalidProperty;

/**
	An arithmetic operator in a CSS value.
**/
enum CssOp {
	/**
		`+`
	**/
	OAdd;
	/**
		`-`
	**/
	OSub;
	/**
		`*`
	**/
	OMult;
	/**
		`/`
	**/
	ODiv;
}

/**
	A parsed CSS value.
**/
enum CssValue {
	/**
		An identifier.
	**/
	VIdent( i : String );
	/**
		A quoted string.
	**/
	VString( s : String );
	/**
		A number with a unit (`10px`, `50%`).
	**/
	VUnit( v : Float, unit : String );
	/**
		A float.
	**/
	VFloat( v : Float );
	/**
		An integer.
	**/
	VInt( v : Int );
	/**
		A hexadecimal color (`#F80`), with its digits and value.
	**/
	VHex( h : String, v : Int );
	/**
		Values separated by commas.
	**/
	VList( l : Array<CssValue> );
	/**
		Values separated by spaces.
	**/
	VGroup( l : Array<CssValue> );
	/**
		A function call (`rgba(...)`, `url(...)`).
	**/
	VCall( f : String, vl : Array<CssValue> );
	/**
		A value with a label (`!important`).
	**/
	VLabel( v : String, val : CssValue );
	/**
		A `/` separator.
	**/
	VSlash;
	/**
		An array access (`a[b]`).
	**/
	VArray( v : CssValue, ?content : CssValue );
	/**
		An arithmetic operation.
	**/
	VOp( op : CssOp, v1 : CssValue, v2 : CssValue );
	/**
		A value in parentheses.
	**/
	VParent( v : CssValue );
	/**
		A variable (`@name`).
	**/
	VVar( name : String );
}

/**
	A color in the HSL color space, used by the `darken`, `lighten`, `saturate` and `desaturate` color functions.
**/
class HSL {
	/**
		The alpha, from `0` to `1`.
	**/
	public var alpha : Float;
	/**
		The hue, in radians.
	**/
	public var hue : Float;
	/**
		The saturation, from `0` to `1`.
	**/
	public var saturation : Float;
	/**
		The lightness, from `0` to `1`.
	**/
	public var lightness : Float;

	/**
		Converts an ARGB color.
	**/
	public function new(color:Int) {
		var r = ((color >> 16) & 0xFF) / 255;
		var g = ((color >> 8) & 0xFF) / 255;
		var b = (color & 0xFF) / 255;
		alpha = (color >>> 24) / 255;
	    var max = hxd.Math.max(hxd.Math.max(r, g), b);
		var min = hxd.Math.min(hxd.Math.min(r, g), b);
		var h, s, l = (max + min) / 2.0;

		if(max == min)
			h = s = 0.0; // achromatic
		else {
			var d = max - min;
			s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
			if(max == r)
				h = (g - b) / d + (g < b ? 6.0 : 0.0);
			else if(max == g)
				h = (b - r) / d + 2.0;
			else
				h = (r - g) / d + 4.0;
			h *= Math.PI / 3.0;
		}
		this.hue = h;
		this.saturation = s;
		this.lightness = l;
	}

	/**
		Returns the ARGB color.
	**/
	public function toColor() {
		var r:Float,g:Float,b:Float;
		var hue = hue % (Math.PI * 2);
		var saturation = saturation;
		if( saturation < 0 ) saturation = 0 else if( saturation > 1 ) saturation = 1;
		if( hue < 0 ) hue += Math.PI * 2;
		var c = (1 - Math.abs(2 * lightness - 1)) * saturation;
		var x = c * (1 - Math.abs((hue * 3 / Math.PI) % 2. - 1));
		var m = lightness - c / 2;
		if( hue < Math.PI / 3 ) {
			r = c;
			g = x;
			b = 0;
		} else if( hue < Math.PI * 2 / 3 ) {
			r = x;
			g = c;
			b = 0;
		} else if( hue < Math.PI ) {
			r = 0;
			g = c;
			b = x;
		} else if( hue < Math.PI * 4 / 3 ) {
			r = 0;
			g = x;
			b = c;
		} else if( hue < Math.PI * 5 / 3 ) {
			r = x;
			g = 0;
			b = c;
		} else {
			r = c;
			g = 0;
			b = x;
		}
		r += m;
		g += m;
		b += m;
		var a = alpha;
		if( r < 0 ) r = 0 else if( r > 1 ) r = 1;
		if( g < 0 ) g = 0 else if( g > 1 ) g = 1;
		if( b < 0 ) b = 0 else if( b > 1 ) b = 1;
		if( a < 0 ) a = 0 else if( a > 1 ) a = 1;
		return (Std.int(a*255 + 0.499) << 24) | (Std.int(r * 255 + 0.499) << 16) | (Std.int(g * 255 + 0.499) << 8) | Std.int(b * 255 + 0.499);
	}
}

/**
	Converts CSS values to property values: the `parseXxx` methods are used by the `@:p(xxx)` fields (`@:p(color)` uses `parseColor`). Extend it to add parsers, and set it with `@:parser` or `domkit.Macros.setDefaultParser`. The methods throw `Property.InvalidProperty` for invalid values.
**/
class ValueParser {

	var defaultColor = 0;

	/**
		Creates the parser.
	**/
	public function new() {
	}

	/**
		Throws an `Property.InvalidProperty` error.
	**/
	public function invalidProp( ?msg ) : Dynamic {
		throw new InvalidProperty(msg);
	}

	/**
		Parses an identifier.
	**/
	public function parseIdent( v : CssValue ) {
		return switch( v ) { case VIdent(v): v; default: invalidProp(); }
	}

	/**
		Parses a string or an identifier.
	**/
	public function parseString( v : CssValue ) {
		return switch( v ) {
		case VIdent(i): i;
		case VString(s): s;
		default: invalidProp();
		}
	}

	/**
		Parses an object id.
	**/
	public function parseId( v : CssValue ) {
		return switch( v ) {
		case VIdent(n): n;
		case VArray(VIdent(n), null): n;
		default: invalidProp();
		}
	}

	static var CSS_COLORS = [
		"maroon" => 0x800000,
		"red" => 0xFF0000,
		"orange" => 0xFFA500,
		"yellow" => 0xFFFF00,
		"olive" => 0x808000,
		"green" => 0x008000,
		"lime" => 0x00FF00,
		"purple" => 0x800080,
		"fuchsia" => 0xFF00FF,
		"teal" => 0x008080,
		"cyan" => 0x00FFFF,
		"aqua" => 0x00FFFF,
		"blue" => 0x0000FF,
		"navy" => 0x000080,
		"black" => 0x000000,
		"gray" => 0x808080,
		"silver" => 0xC0C0C0,
		"white" => 0xFFFFFF,
	];

	/**
		Parses a color, as an ARGB integer: `#RGB`, `#RRGGBB`, `rgb(r,g,b)`, `rgba(r,g,b,a)`, CSS color names, `darken(c,10%)`, `lighten(c,10%)`, `saturate(c,10%)`, `desaturate(c,10%)`, and `color alpha`.
	**/
	public function parseColor( v : CssValue ) {
		switch( v ) {
		case VHex(h,color):
			if( h.length == 3 ) {
				var r = color >> 8;
				var g = (color & 0xF0) >> 4;
				var b = color & 0xF;
				r |= r << 4;
				g |= g << 4;
				b |= b << 4;
				color = (r << 16) | (g << 8) | b;
			}
			return color | 0xFF000000;
		case VCall("rgba", [r,g,b,a]):
			var r = parseInt(r);
			var g = parseInt(g);
			var b = parseInt(b);
			var a = parseFloat(a);
			return (Std.int(clamp(r,0,255)) << 16)
				| (Std.int(clamp(g,0,255)) << 8)
				| Std.int(clamp(b,0,255))
				| (Std.int(clamp(a,0,1)*255) << 24);
		case VCall("rgb", [r,g,b]):
			var r = parseInt(r);
			var g = parseInt(g);
			var b = parseInt(b);
			return (Std.int(clamp(r,0,255)) << 16)
				| (Std.int(clamp(g,0,255)) << 8)
				| Std.int(clamp(b,0,255))
				| 0xFF000000;
		case VIdent(i):
			var c = CSS_COLORS.get(i);
			if( c == null ) invalidProp();
			return c | 0xFF000000;
		case VCall("darken",[color,VUnit(percent,"%")]):
			var c = parseColor(color);
			var c = new HSL(c);
			c.lightness -= percent / 100;
			return c.toColor();
		case VCall("lighten",[color,VUnit(percent,"%")]):
			var c = parseColor(color);
			var c = new HSL(c);
			c.lightness += percent / 100;
			return c.toColor();
		case VCall("saturate",[color,VUnit(percent,"%")]):
			var c = parseColor(color);
			var c = new HSL(c);
			c.saturation += percent / 100;
			return c.toColor();
		case VCall("desaturate",[color,VUnit(percent,"%")]):
			var c = parseColor(color);
			var c = new HSL(c);
			c.saturation -= percent / 100;
			return c.toColor();
		case VGroup([color,VFloat(alpha)]):
			var c = parseColor(color);
			return (c & 0xFFFFFF) | (Std.int((alpha < 0 ? 0 : alpha > 1 ? 1 : alpha) * 255) << 24);
		default:
			return invalidProp();
		}
	}

	/**
		Interpolates between two ARGB colors.
	**/
	public function transitionColor( a : Null<Int>, b : Null<Int>, p : Float ) {
		var a : Int = a == null ? defaultColor : a;
		var b : Int = b == null ? defaultColor : b;
		inline function lerp(a:Int,b:Int) {
			return Std.int((b - a) * p) + a;
		}
		return lerp(a & 0xFF, b & 0xFF) | (lerp((a >> 8) & 0xFF, (b >> 8) & 0xFF) << 8) | (lerp((a >> 16) & 0xFF, (b >> 16) & 0xFF) << 16) | (lerp((a >>> 24) & 0xFF, (b >>> 24) & 0xFF) << 24);
	}

	static inline function clamp(f:Float,min:Float,max:Float) {
		return f < min ? min : (f > max ? max : f);
	}

	/**
		Parses values separated by spaces, with `elt`.
	**/
	public function parseArray<T>( elt : CssValue -> T, v : CssValue ) : Array<T> {
		return switch( v ) {
		case VGroup(vl): [for( v in vl ) elt(v)];
		default: [elt(v)];
		}
	}

	/**
		Parses a path: a string, an identifier or `url(path)`.
	**/
	public function parsePath( v : CssValue ) {
		return switch( v ) {
		case VString(v): v;
		case VIdent(v): v;
		case VCall("url",[VIdent(v) | VString(v)]): v;
		default: invalidProp();
		}
	}

	/**
		Parses a boolean: `true`, `false`, `1` or `0`.
	**/
	public function parseBool( v : CssValue ) : Null<Bool> {
		return switch( v ) {
		case VIdent("true") | VInt(1): true;
		case VIdent("false") | VInt(0): false;
		default: invalidProp();
		}
	}

	/**
		Returns `null` for `auto`, or parses the value with `either`.
	**/
	public function parseAuto<T>( either : CssValue -> T, v : CssValue ) : Null<T> {
		return v.match(VIdent("auto")) ? null : either(v);
	}

	/**
		Returns `null` for `none`, or parses the value with `either`.
	**/
	public function parseNone<T>( either : CssValue -> T, v : CssValue ) : Null<T> {
		return v.match(VIdent("none")) ? null : either(v);
	}

	/**
		Parses an integer.
	**/
	public function parseInt( v : CssValue ) : Null<Int> {
		return switch( v ) {
		case VInt(i): i;
		default: invalidProp();
		}
	}

	/**
		Parses a number.
	**/
	public function parseFloat( v : CssValue ) : Float {
		return switch( v ) {
		case VInt(i): i;
		case VFloat(f): f;
		default: invalidProp();
		}
	}

	/**
		Parses a number, or a percentage as a ratio (`50%` is `0.5`).
	**/
	public function parseFloatPercent( v : CssValue ) : Float {
		return switch( v ) {
		case VUnit(v,"%"): v / 100;
		default: parseFloat(v);
		}
	}

	/**
		Parses two numbers, as `{ x, y }`.
	**/
	public function parseXY( v : CssValue ) {
		return switch( v ) {
		case VGroup([x,y]): { x : parseFloat(x), y : parseFloat(y) };
		default: invalidProp();
		}
	}

	/**
		Parses 1 to 4 integers as `{ top, right, bottom, left }`, like the CSS `padding`.
	**/
	public function parseBox( v : CssValue ) {
		switch( v ) {
		case VInt(v):
			return { top : v, right : v, bottom : v, left : v };
		case VGroup([VInt(v),VInt(h)]):
			return { top : v, right : h, bottom : v, left : h };
		case VGroup([VInt(v),VInt(h),VInt(k)]):
			return { top : v, right : h, bottom : k, left : h };
		case VGroup([VInt(v),VInt(h),VInt(k),VInt(l)]):
			return { top : v, right : h, bottom : k, left : l };
		default:
			return invalidProp();
		}
	}

	/**
		Parses 1 to 4 values with `f`, as `{ top, right, bottom, left }`, like the CSS `padding`.
	**/
	public function parseGenBox<T>( v : CssValue, f : CssValue -> T ) {
		switch( v ) {
		case VGroup([v,h]):
			var v = f(v);
			var h = f(h);
			return { top : v, right : h, bottom : v, left : h };
		case VGroup([v,h,k]):
			var v = f(v);
			var h = f(h);
			var k = f(k);
			return { top : v, right : h, bottom : k, left : h };
		case VGroup([v,h,k,l]):
			var v = f(v);
			var h = f(h);
			var k = f(k);
			var l = f(l);
			return { top : v, right : h, bottom : k, left : l };
		default:
			var v = f(v);
			return { top : v, right : v, bottom : v, left : v };
		}
	}

	/**
		Returns a parser of the constructors of the enum, in CSS casing (`TopLeft` is `top-left`) or lower case.
	**/
	public function makeEnumParser<T:EnumValue>( e : Enum<T> ) : CssValue -> T {
		var h = new Map();
		var all = [];
		for( v in e.createAll() ) {
			var id = CssParser.haxeToCss(v.getName());
			h.set(id, v);
			all.push(id);
			h.set(v.getName().toLowerCase(), v);
		}
		var choices = all.join("|");
		return function( v : CssValue ) {
			return switch( v ) {
			case VIdent(i):
				var v = h.get(i);
				if( v == null ) invalidProp(i+" should be "+choices);
				return v;
			default:
				invalidProp();
			}
		}

	}

}