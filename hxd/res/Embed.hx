package hxd.res;
import haxe.macro.Context;

#if js @:keep #end
class Embed {

	#if macro
	static function locateFont( file : String ) {
		try {
			return Context.resolvePath(file);
		} catch( e : Dynamic ) {
		}
		if( Sys.systemName() == "Windows" ) {
			var path = Sys.getEnv("SystemRoot") + "\\Fonts\\" + file;
			if( sys.FileSystem.exists(path) )
				return path;
		}
		return null;
	}

	public static function doEmbedFont( name : String, file : String, chars : String ) {

		var m = Context.getLocalClass().get().module;
		Context.registerModuleDependency(m, file);

		if( Context.defined("flash") || Context.defined("openfl") ) {
			if( chars == null ) // convert char list to char range
				chars = Charset.DEFAULT_CHARS.split("-").join("\\-");
			var pos = Context.currentPos();
			haxe.macro.Context.defineType({
				pack : ["hxd","_res"],
				name : name,
				meta : [
					{ name : ":native", pos : pos, params : [macro $v { "_"+name } ] },
					{ name : ":font", pos : pos, params : [macro $v { file }, macro $v { chars } ] },
					{ name : ":keep", pos : pos, params : [] }
				],
				kind : TDClass({ pack : ["flash","text"], name : "Font", params : [] }),
				params : [],
				pos : pos,
				isExtern : false,
				fields : [],
			});
			return macro new hxd._res.$name().fontName;
		} else if( Context.defined("js") ) {
			// TODO : we might want to extract the chars from the TTF font
			var pos = Context.currentPos();
			var content = haxe.crypto.Base64.encode(sys.io.File.getBytes(Context.resolvePath(file)));
			haxe.macro.Context.defineType({
				pack : ["hxd", "_res"],
				name : name,
				meta : [
					{ name : ":keep", pos : pos },
				],
				pos : pos,
				kind : TDClass({ pack : ["hxd","res"], name : "Embed", params : [] }),
				fields : [
					{
						pos : pos,
						name : "__init__",
						access : [AStatic],
						kind : FFun( {
							ret : macro : Void,
							args : [],
							expr : macro untyped hx__registerFont($v{name},$v{content}),
						}),
					}
				],
			});

			return { expr : EConst(CString(name)), pos : pos };

		} else
			throw "Font embedding not available for this platform";
	}

	#end
	
	/**
	  宏方法, 独立于 Res 类(不需要从 Res 初使化), 以 字符串的形式嵌入,  返回文件文本内容
	*/
	public static macro function getFileContent( file : String ) {
		var file = Context.resolvePath(file);
		var m = Context.getLocalClass().get().module;
		Context.registerModuleDependency(m, file);
		return macro $v{sys.io.File.getContent(file)};
	}
	
	/**
	  宏方法, 独立于 Res 类(不需要从 Res 初使化), 以 Serializer/Unserializer 的方式 嵌入资源文件   
	*/
	public static macro function getResource( file : String ) {
		var path = Context.resolvePath(file);
		var m = Context.getLocalClass().get().module;
		Context.registerModuleDependency(m, path);
		var str = haxe.Serializer.run(sys.io.File.getBytes(path));
		return macro hxd.res.Any.fromBytes($v{file},haxe.Unserializer.run($v{str}));
	}
	
	/**
		宏方法, 独立于 Res 类(不需要从 Res 初使化), 直接嵌入字体, 嵌入字体后将自动生成 hxd._res.safeName 的 类.
		
		flash 或 openfl 平台将返回 ttf 的字体描述名称(非文件名,而是双击打开 ttf之后看到的字体名称),
		
		```		
		
		var nokiafc22:String = Embed.embedFont("nokiafc22.ttf");
		
		// 在 flash.text.TextField 中引用.
		var tf = new flash.text.TextField();
		tf.defaultTextFormat = new flash.text.TextFormat(nokiafc22, 16, 0xffffff);
		tf.embedFonts = true;
		tf.text = "Hello, flash";
		Lib.current.addChild(tf);
		
		
		// 在 这个引擎的 h2d 中引用
		var ft:h2d.Font = FontBuilder.getFont(nokiafc22, 16);
		var tf2:h2d.Text = new Text(ft, s2d);
		tf2.text = "Hello, stage3D";
		
		```
		
	@file 字体文件名, 第一步将会查找 Context.resolvePath(file) 所对应的文件名, 如果没有则从 windows\FONT\ 查找对应的字体嵌入.
	
	@chars 默认为 Charset.DEFAULT_CHARS
	
	@skipErrors
	*/
	public macro static function embedFont( file : String, ?chars : String, ?skipErrors : Bool ) {
		var ok = true;
		var path = locateFont(file);
		if( path == null ) {
			if( !skipErrors ) Context.error("Font file not found " + file,Context.currentPos());
			return macro null;
		}
		var safeName = "R_"+~/[^A-Za-z0-9_]+/g.replace(file, "_");
		return doEmbedFont(safeName, path, chars);
	}

	#if js
	static function __init__() untyped {
		__js__("var hx__registerFont");
		untyped hx__registerFont = function(name, data) {
			var s = js.Browser.document.createStyleElement();
			s.type = "text/css";
			s.innerHTML = "@font-face{ font-family: " + name + "; src: url('data:font/ttf;base64," + data + "') format('truetype'); }";
			js.Browser.document.getElementsByTagName('head')[0].appendChild(s);
			// create a div in the page to force font loading
			var div = js.Browser.document.createDivElement();
			div.style.fontFamily = name;
			div.style.opacity = 0;
			div.style.width = "1px";
			div.style.height = "1px";
			div.style.position = "fixed";
			div.style.bottom = "0px";
			div.style.right = "0px";
			div.innerHTML = ".";
			div.className = "hx__loadFont";
			js.Browser.document.body.appendChild(div);
		};
	}
	#end

}