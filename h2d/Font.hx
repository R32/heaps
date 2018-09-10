package h2d;

class Kerning {
	public var prevChar : Int;
	public var offset : Int;
	public var next : Null<Kerning>;
	public function new(c, o) {
		this.prevChar = c;
		this.offset = o;
	}
}

@:allow(h2d.Font)
class FontChar {

	public var t : h2d.Tile;
	public var width : Int;
	var kerning : Null<Kerning>;
	var next: Null<FontChar>;
	var code: Int;

	public function new(t,w,c) {
		this.t = t;
		this.width = w;
		this.code = c;
	}

	public function addKerning( prevChar : Int, offset : Int ) {
		var k = new Kerning(prevChar, offset);
		k.next = kerning;
		kerning = k;
	}

	public function getKerningOffset( prevChar : Int ) {
		var k = kerning;
		while( k != null ) {
			if( k.prevChar == prevChar )
				return k.offset;
			k = k.next;
		}
		return 0;
	}

	public function clone() {
		var c = new FontChar(t.clone(), width, code);
		c.kerning = kerning;
		return c;
	}

}

class Font {

	public var name(default, null) : String;
	public var size(default, null) : Int;
	public var baseLine(default, null) : Int;
	public var lineHeight(default, null) : Int;
	public var tile(default,null) : h2d.Tile;
	public var charset : hxd.Charset;
	var glyphs: haxe.ds.Vector<FontChar>;
	var bits: Int;
	var nchars: Int;
	var nullChar : FontChar;
	var defaultChar : FontChar;
	var initSize:Int;
	var offsetX:Int = 0;
	var offsetY:Int = 0;

	function new(name,size,nchars) {
		this.name = name;
		this.size = size;
		this.initSize = size;
		this.nchars = nchars;
		this.bits = bitsWidth(nchars);
		glyphs = new haxe.ds.Vector(1 << this.bits);
		defaultChar = nullChar = new FontChar(new Tile(null, 0, 0, 0, 0),0, 0);
		charset = hxd.Charset.getDefault();
	}

	public function getChar( code : Int ) {
		var c = glyphs.get(hash(code));
		while (c != null) {
			if (c.code == code)
				return c;
			c = c.next;
		}
		if (c == null) {
			var mapp:Null<Int> = charset.resolveChar(code);
			while (mapp != null) {
				c = glyphs.get(hash(mapp));
				while (c != null) {
					if (c.code == mapp)
						break;
					c = c.next;
				}
				if (c != null)
					break;
				mapp = charset.resolveChar(mapp);
			}
			if (c == null)
				c = code == "\r".code || code == "\n".code ? nullChar : defaultChar;
		}
		return c;
	}

	public function addChar( c: FontChar ) {
		var pos = hash(c.code);
		c.next = glyphs.get(pos);
		glyphs.set(pos, c);
	}

	public function setOffset(x,y) {
		var dx = x - offsetX;
		var dy = y - offsetY;
		if( dx == 0 && dy == 0 ) return;
		for ( i in 0...glyphs.length ) {
			var c = glyphs[i];
			while (c != null) {
				c.t.dx += dx;
				c.t.dy += dy;
				c = c.next;
			}
		}
		this.offsetX += dx;
		this.offsetY += dy;
	}

	public function clone() {
		var f = new Font(name, size, this.nchars);
		f.baseLine = baseLine;
		f.lineHeight = lineHeight;
		f.tile = tile.clone();
		f.charset = charset;
		f.defaultChar = defaultChar.clone();
		for ( i in 0...glyphs.length ) {
			var c = glyphs[i];
			if (c == null) continue;
			var c2 = c.clone();
			f.glyphs[i] = c2;
			while (c.next != null) {
				c2.next = c.next.clone();
				c2 = c2.next;
				c = c.next;
			}
		}
		return f;
	}

	/**
		This is meant to create smoother fonts by creating them with double size while still keeping the original glyph size.
	**/
	public function resizeTo( size : Int ) {
		var ratio = size / initSize;
		for ( i in 0...glyphs.length ) {
			var c = glyphs[i];
			while (c != null) {
				c.width = Std.int(c.width * ratio);
				c.t.scaleToSize(Std.int(c.t.width * ratio), Std.int(c.t.height * ratio));
				c.t.dx = Std.int(c.t.dx * ratio);
				c.t.dy = Std.int(c.t.dy * ratio);
				c = c.next;
			}
		}
		lineHeight = Std.int(lineHeight * ratio);
		baseLine = Std.int(baseLine * ratio);
		this.size = size;
	}

	public function hasChar( code : Int ) {
		return glyphs.get(code) != null;
	}

	public function dispose() {
		tile.dispose();
	}

	inline function hash(i) return (i * 0x61C88647) >>> (32 - this.bits);

	inline function bitsWidth(n: Int) return Std.int(Math.log(n) * 1.4426950408889634 + 0.999999999);
}
