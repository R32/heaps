package hxd;

/**
* 等待, 直到回调函数返回 true, 才移除回调函数, 需要将 update 放入到 MainLoop 中去.
*/
class WaitEvent {

	var updateList : Array<Float -> Bool> ;

	public function new() {
		updateList = [];
	}

	public inline function hasEvent() {
		return updateList.length > 0;
	}

	public function clear() {
		updateList = [];
	}

	public function add( callb ) {
		updateList.push(callb);
	}

	public function remove( callb : Float->Bool ) {
		for( e in updateList )
			if( Reflect.compareMethods(e, callb) ) {
				updateList.remove(e);
				return true;
			}
		return false;
	}

	public function wait( time : Float, callb ) {
		function tmp(dt:Float) {
			time -= dt / hxd.Timer.wantedFPS;
			if( time < 0 ) {
				callb();
				return true;
			}
			return false;
		}
		updateList.push(tmp);
	}

	public function waitUntil( callb ) {
		updateList.push(callb);
	}

	public function update(dt:Float) {
		if( updateList.length == 0 ) return;
		for( f in updateList.copy() )
			if( f(dt) )
				updateList.remove(f);
	}

}