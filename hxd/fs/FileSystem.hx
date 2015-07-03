package hxd.fs;

/**
* 文件接口, 建立在 FileEntry 之上
*/
interface FileSystem {
	public function getRoot() : FileEntry;
	public function get( path : String ) : FileEntry;
	public function exists( path : String ) : Bool;
	public function dispose() : Void;
}