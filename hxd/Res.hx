package hxd;

/**
  https://github.com/ncannasse/r32/wiki/Resource-Management

  定义 `-D resourcesPath=dir` 之后, 将会自动扫描 这个文件夹下的文件,并给IDE提供 智能提示
  默认文件夹为 res. 资源文件夹下所有以 `.` 或 `_` 开头的目录将被忽略.

  资源通过其扩展名将作如下转换(`hxd/res/FileTree::handleFile`):
   - png,jpg,jpeg,gif: hxd.res.Image
   - wav,mp3,ogg : hxd.res.Sound
   - fbx,hmd: hxd.res.Model
   - fnt(png): hxd.res.BitmapFont
   - ttf: hxd.res.Font
   - tmx: hxd.res.TiledMap
   - atlas: hxd.res.Atlas
   - 其它: hxd.res.Resource(允许二进制数据)

   Res.loader 实际上就是 Loader.currentInstance, 宏会在编译时自动处理这个,或者也可以通过代码手动管理。
*/
#if !macro
@:build(hxd.res.FileTree.build())
#end
class Res {

	#if !macro
	/**
	 获得指定资源(Any类型)(需要在initXXXX初使化之后)，
	 大多数情况下都不需要调用这个, 但是如果你想要动态加载资源, 如循环加载 1~N 个图片
	*/
	public static function load(name:String) {
		return loader.load(name);
	}
	#end

	/**
		以 embed 的形式嵌入资源, 通过宏建立并初使化 loader 属性。
	*/
	public static macro function initEmbed(?options:haxe.macro.Expr.ExprOf<hxd.res.EmbedOptions>) {
		return macro hxd.Res.loader = new hxd.res.Loader(hxd.fs.EmbedFileSystem.create(null,$options));
	}

	#if lime
	public static macro function initLime() {
		return macro hxd.Res.loader = new hxd.res.Loader(new hxd.fs.LimeFileSystem());
	}
	#end

	/**
		以 本地文件的形式处理资源, 通过宏建立并初使化 loader 属性
		需要 flash Air 或者支持 Sys
	*/
	public static macro function initLocal() {
		var dir = haxe.macro.Context.definedValue("resourcesPath");
		if( dir == null ) dir = "res";
		return macro hxd.Res.loader = new hxd.res.Loader(new hxd.fs.LocalFileSystem($v{dir}));
	}

	/**
	 目前需要本地文件系统支持，如果 flash 则需要打包成 AIR，否则你只能尝试运行时加载 pak 包。

	 加载 res.pak 压缩包, 将 res 目录打包成 pak 文件命令为 `haxelib run heaps pak [res]`

	 注: 在 win 系统上你可能需要通过其它方式手动创建 .tmp 这个目录
	*/
	public static macro function initPak( ?file : String ) {
		if( file == null )
			file = haxe.macro.Context.definedValue("resourcesPath");
		if( file == null )
			file = "res";
		return macro {
			var file = $v{file};
			#if usesys
			file = haxe.System.dataPathPrefix + file;
			#end
			var pak = new hxd.fmt.pak.FileSystem();
			pak.loadPak(file + ".pak");
			var i = 1;
			while( true ) {
				if( !hxd.File.exists(file + i + ".pak") ) break;
				pak.loadPak(file + i + ".pak");
				i++;
			}
			hxd.Res.loader = new hxd.res.Loader(pak);
		}
	}

}
