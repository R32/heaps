package hxd.res;

/**
默认的资源类，如果某个资源不能被识别为 声音,图片,字体 FBX模型,之类的资源
*/
class Resource {

	public static var LIVE_UPDATE = #if debug true #else false #end;

	public var name(get, never) : String;
	public var entry(default,null) : hxd.fs.FileEntry;

	public function new(entry) {
		this.entry = entry;
	}

	inline function get_name() {
		return entry.name;
	}

	function toString() {
		return entry.path;
	}

	public function watch( onChanged : Null < Void -> Void > ) {
		if( LIVE_UPDATE	) entry.watch(onChanged);
	}

}