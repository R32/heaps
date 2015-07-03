package hxd;

class Timer {

	public static var wantedFPS = 60.;
	public static var maxDeltaTime = 0.5;
	public static var oldTime = haxe.Timer.stamp();
	public static var tmod_factor = 0.95;
	public static var calc_tmod : Float = 1;

	/**
	* 当这个值为 1 时. fps() 的返回值 等于 wantedFPS.
	* 当这个值大于 1 时, 说明出现掉帧现象,
	* 所以可以 ENTER_FRAME 方法内使用类似于 speed * Timer.tmod 来平滑动画.
	*/
	public static var tmod : Float = 1;

	/**
	* 上一帧到这一帧所花费的时间,单位为: 秒.
	*/
	public static var deltaT : Float = 1;
	static var frameCount = 0;

	/**
	*  需要在 ENTER_FRAME 事件中调用这个方法以更新 tmod 值
	*/
	public static function update() {
		frameCount++;
		var newTime = haxe.Timer.stamp();
		deltaT = newTime - oldTime;
		oldTime = newTime;
		if( deltaT < maxDeltaTime )
			calc_tmod = calc_tmod * tmod_factor + (1 - tmod_factor) * deltaT * wantedFPS;
		else
			deltaT = 1 / wantedFPS;
		tmod = calc_tmod;
	}

	public inline static function fps() : Float {
		return wantedFPS/calc_tmod;
	}

	/**
	* 跳过???
	* 当游戏就绪运行时,需要刷新下 oldTime
	* 或者 从暂停的游戏恢复时, oldTime 会变得非常大,这里调用这个方法,刷新下这个值
	*/
	public static function skip() {
		oldTime = haxe.Timer.stamp();
	}

	public static function reset() {
		oldTime = haxe.Timer.stamp();
		calc_tmod = 1.;
	}

}
