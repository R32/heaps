package hxd.res;
#if (haxe_ver < 4)
import haxe.xml.Fast in Access;
#else
import haxe.xml.Access;
#end

class BitmapFont extends Resource {

	var loader : Loader;
	var font : h2d.Font;

	public function new(entry) {
		super(entry);
		this.loader = hxd.res.Loader.currentInstance;
	}

	@:access(h2d.Font)
	public function toFont() : h2d.Font {
		if( font != null )
			return font;
		var tile = loader.load(entry.path.substr(0, -3) + "png").toTile();
		var name = entry.path, size = 0, lineHeight = 0;
		switch( entry.getSign() ) {
		case 0x6D783F3C: // <?xml : XML file
			var xml = Xml.parse(entry.getBytes().toString());
			// support only the FontBuilder/Divo format
			// export with FontBuilder https://github.com/andryblack/fontbuilder/downloads
			var xml = new Access(xml.firstElement());
			size = Std.parseInt(xml.att.size);
			lineHeight = Std.parseInt(xml.att.height);
			name = xml.att.family;
			var chars:Array<Access> = cast [for (child in @:privateAccess xml.x.children) if (child.nodeType == Element) child];
			font = new h2d.Font(name, size, chars.length);
			for( c in chars ) {
				var r = c.att.rect.split(" ");
				var o = c.att.offset.split(" ");
				var t = tile.sub(Std.parseInt(r[0]), Std.parseInt(r[1]), Std.parseInt(r[2]), Std.parseInt(r[3]), Std.parseInt(o[0]), Std.parseInt(o[1]));
				var s = c.att.code;
				var code = StringTools.startsWith(s, "&#") ? Std.parseInt(s.substr(2, s.length - 3)) : s.charCodeAt(0);
				var fc = new h2d.Font.FontChar(t, Std.parseInt(c.att.width) - 1, code);
				for( k in c.elements )
					fc.addKerning(k.att.id.charCodeAt(0), Std.parseInt(k.att.advance));
				font.addChar(fc);
			}
		case 0x6E6F663C:
			// support for Littera XML format (starts with <font>)
			// http://kvazars.com/littera/
			var xml = Xml.parse(entry.getBytes().toString());
			var xml = new Access(xml.firstElement());
			size = Std.parseInt(xml.node.info.att.size);
			lineHeight = Std.parseInt(xml.node.common.att.lineHeight);
			name = xml.node.info.att.face;
			var chars = xml.node.chars.elements;
			font = new h2d.Font(name, size, Std.parseInt(xml.node.chars.att.count));
			for( c in chars) {
				var t = tile.sub(Std.parseInt(c.att.x), Std.parseInt(c.att.y), Std.parseInt(c.att.width), Std.parseInt(c.att.height), Std.parseInt(c.att.xoffset), Std.parseInt(c.att.yoffset));
				var fc = new h2d.Font.FontChar(t, Std.parseInt(c.att.width) - 1, Std.parseInt(c.att.id));
				var kerns = xml.node.kernings.elements;
				for (k in kerns)
					if (k.att.second == c.att.id)
						fc.addKerning(Std.parseInt(k.att.first), Std.parseInt(k.att.amount));

				font.addChar(fc);
			}
		case sign:
			throw "Unknown font signature " + StringTools.hex(sign, 8);
		}
		if (font.getChar(" ".code) == null)
			font.addChar(new h2d.Font.FontChar(tile.sub(0, 0, 0, 0), size>>1, " ".code));

		font.lineHeight = lineHeight;
		font.tile = tile;

		var padding = 0;
		var space = font.getChar(" ".code);
		if( space != null )
			padding = (space.t.height >> 1);

		var a = font.getChar("A".code);
		if( a == null )
			a = font.getChar("a".code);
		if( a == null )
			a = font.getChar("0".code); // numerical only
		if( a == null )
			font.baseLine = font.lineHeight - 2 - padding;
		else
			font.baseLine = a.t.dy + a.t.height - padding;

		var fallback = font.getChar(0xFFFD); // <?>
		if( fallback == null )
			fallback = font.getChar(0x25A1); // square
		if( fallback != null )
			font.defaultChar = fallback;

		return font;
	}

}
