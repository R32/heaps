package hxd.res;
/**
资源将挂载在这个类上, 将优先使用 cache 里的资源, 不存在则通过 path 从 filesystem 中获取
*/
class Loader {

	/**
		Set when initializing hxd.Res, or manually.
		Allows code to resolve resources without compiling hxd.Res

		实际上 hxd.Res.loader 是一个 getter/getter 和这个属性关联，即它们是同一个值。

		如果你没有调用 hxd.Res 的初始化方法，可以手动设置这个值。
	*/
	public static var currentInstance : Loader;

	public var fs(default,null) : hxd.fs.FileSystem;
	var cache : Map<String,Dynamic>;

	public function new(fs) {
		this.fs = fs;
		cache = new Map<String,Dynamic>();
	}

	public function cleanCache() {
		cache = new Map();
	}

	public function exists( path : String ) : Bool {
		return fs.exists(path);
	}

	public function load( path : String ) : Any {
		return new Any(this, fs.get(path));
	}

	public function loadCache<T:hxd.res.Resource>( path : String, c : Class<T> ) : T {
		var res : T = cache.get(path);
		if( res == null ) {
			var entry = fs.get(path);
			var old = currentInstance;
			currentInstance = this;
			res = Type.createInstance(c, [entry]);
			currentInstance = old;
			cache.set(path, res);
		}
		return res;
	}

	public function dispose() {
		cleanCache();
		fs.dispose();
	}

}