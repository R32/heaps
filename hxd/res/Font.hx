package hxd.res;

/**
用于表示 res 资源文件夹下的字体文件, 这个方法将通过 FontBuilder 来动态创建字体图贴(tile)

由于感觉动态创建字体不太好，因此建议使用 BitmapFont
*/
class Font extends Resource {

	public function build( size : Int, ?options ) : h2d.Font {
		#if lime
		return FontBuilder.getFont(name, size, options);
		#elseif flash
		var fontClass : Class<flash.text.Font> = cast Type.resolveClass("_R_" + ~/[^A-Za-z0-9_]/g.replace(entry.path, "_"));
		if( fontClass == null ) throw "Embeded font not found " + entry.path;
		var font = Type.createInstance(fontClass, []);
		return FontBuilder.getFont(font.fontName, size, options);
		#elseif js
		var name = "R_" + ~/[^A-Za-z0-9_]/g.replace(entry.path, "_");
		return FontBuilder.getFont(name, size, options);
		#else
		throw "Not implemented for this platform";
		return null;
		#end
	}

}
