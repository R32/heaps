package hxd.res;

private class SingleFileSystem extends hxd.fs.BytesFileSystem {

	var path : String;
	var bytes : haxe.io.Bytes;

	public function new(path, bytes) {
		super();
		this.path = path;
		this.bytes = bytes;
	}

	override function getBytes(p) {
		return p == path ? bytes : null;
	}

}
/**
  表示一个任意类型资源, 必须需要知道文件类型, 才能够调用相应方法以得到想要的资源类型。
  
  例如: 假如知道是文本文件, 那么可以在 new Any() 之后调用 toText(), 
  
  一般情况下不需要用到这个类, 它只是通常被 Loader 调用, 因为这个类只是从 loader 属性中取值,
  例如: toFbx 与 Loader 类中的 loadFbxModel 方法是一样的.
*/
@:access(hxd.res.Loader)
class Any extends Resource {

	var loader : Loader;

	public function new(loader, entry) {
		super(entry);
		this.loader = loader;
	}

	public function toModel() {
		return loader.loadCache(entry.path, hxd.res.Model);
	}

	public function toTexture() {
		return toImage().toTexture();
	}

	public function toTile() {
		return toImage().toTile();
	}

	public function toText() {
		return entry.getBytes().toString();
	}

	public function toImage() {
		return loader.loadCache(entry.path, hxd.res.Image);
	}

	public function toSound() {
		return loader.loadCache(entry.path, hxd.res.Sound);
	}

	public function toPrefab() {
		return loader.loadCache(entry.path, hxd.res.Prefab);
	}

	public function to<T:hxd.res.Resource>( c : Class<T> ) : T {
		return loader.loadCache(entry.path, c);
	}

	public inline function iterator() {
		return new hxd.impl.ArrayIterator([for( f in entry ) new Any(loader,f)]);
	}

	/**
	 可用于运行时通过二进制数据加载资源. 可以通过 hxd.net.BinaryLoader(目前仅支持flash) 从网络加载资源。
	*/
	public static function fromBytes( path : String, bytes : haxe.io.Bytes ) {
		var fs = new SingleFileSystem(path,bytes);
		return new Loader(fs).load(path);
	}

}