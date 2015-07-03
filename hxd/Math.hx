package hxd;

/**
包装并且扩展了 Std.Math

正三角函数, 已知角度或弧度, 求直角三角形的任意二条边比率, 直角三角形的锐角不可能大于或等于 90 度,

反三角函数, 就是三角函数的逆运算, 即已知直角三角形的任意两条边比率，求角度或弧度值。
*/
class Math {

	public static inline var PI = 3.14159265358979323;
	public static inline var EPSILON = 1e-10;

	public static var POSITIVE_INFINITY(get, never) : Float;
	public static var NEGATIVE_INFINITY(get, never) : Float;
	public static var NaN(get, never) : Float;

	static inline function get_POSITIVE_INFINITY() {
		return std.Math.POSITIVE_INFINITY;
	}

	static inline function get_NEGATIVE_INFINITY() {
		return std.Math.NEGATIVE_INFINITY;
	}

	static inline function get_NaN() {
		return std.Math.NaN;
	}

	public static inline function isNaN(v:Float) {
		return std.Math.isNaN(v);
	}

	/**
	  round to 4 significant digits, eliminates < 1e-10

	  保留小数部分 4 位有效数字, 例: 0.12345 => 0.1234, 1.12345 => 1.123, 12.12345 => 12.12, 123.12345 => 123.1, 1234.1234 => 1234.1
	*/
	public static function fmt( v : Float ) {
		var neg;
		if( v < 0 ) {
			neg = -1.0;
			v = -v;
		} else
			neg = 1.0;
		if( std.Math.isNaN(v) || !std.Math.isFinite(v) )
			return v;
		var digits = Std.int(4 - std.Math.log(v) / std.Math.log(10));
		if( digits < 1 )
			digits = 1;
		else if( digits >= 10 )
			return 0.;
		var exp = pow(10,digits);
		return std.Math.ffloor(v * exp + .49999) * neg / exp;
	}

	/**
	 返回指定数字或表达式的 下限值。下限值是 小于 等于该数字的最接近的整数
	*/
	public static inline function floor( f : Float ) {
		return std.Math.floor(f);
	}

	/**
	 返回指定数字或表达式的 上限值。上限值是 大于 等于该数字的最接近的整数。
	*/
	public static inline function ceil( f : Float ) {
		return std.Math.ceil(f);
	}

	/**
	 四舍五入
	*/
	public static inline function round( f : Float ) {
		return std.Math.round(f);
	}

	/**
	 将 f 值限定在 min 与 max 之间
	*/
	public static inline function clamp( f : Float, min = 0., max = 1. ) {
		return f < min ? min : f > max ? max : f;
	}

	/**
	 计算并返回 v 的 p 次幂。
	*/
	public static inline function pow( v : Float, p : Float ) {
		return std.Math.pow(v,p);
	}

	/**
	 以弧度为单位计算并返回指定角度的 余弦值。 邻边/斜边。参数取值范围 [-∞,+∞]，返回值在 -1.0 ~ 1.0 之间

	 画图为:  -90(0.) ~ 0(1.) ~ 90(0.) ~ 180(-1.) ~ 270(0.) ~ 360(1.) ~ 90(0.)
	*/
	public static inline function cos( f : Float ) {
		return std.Math.cos(f);
	}

	/**
	 以弧度为单位计算并返回指定角度的 正弦值。 对边/斜边。参数取值范围 [-∞,+∞]，返回值在 -1.0 ~ 1.0 之间

	 画图为:  -90(-1.) ~ 0(0.) ~ 90(1.) ~ 180(0.) ~ 270(-1.) ~ 360(0) ~ 90(1.)
	*/
	public static inline function sin( f : Float ) {
		return std.Math.sin(f);
	}

	/**
	 以弧度为单位计算并返回指定角度的 正切值。 对边/邻边。返回值取值范围 [-∞,+∞]

	 画图为: 虽然 -45(-1.) ~ 0(0.) 45(1.), 但是.....
	*/
	public static inline function tan( f : Float ) {
		return std.Math.tan(f);
	}

	/**
	 已知余弦值 f,求的锐角的弧度, 参数值在 -1.0 ~ 1.0 之间, 返回值在 PI ~ 0 之间
	*/
	public static inline function acos( f : Float ) {
		return std.Math.acos(f);
	}

	/**
	 已知正弦值 f, 求的锐角的弧度, 参数值在 -1.0 ~ 1.0 之间, 返回值在 -PI/2 ~ PI/2 之间
	*/
	public static inline function asin( f : Float ) {
		return std.Math.asin(f);
	}

	/**
	 已知正切值 f, 求的锐角的弧度, 返回值在 -PI/2 ~ PI/2 之间
	*/
	public static inline function atan( f : Float ) {
		return std.Math.atan(f);
	}

	/**
	 返回f 的平方根, f 的值必须大于等于 0
	*/
	public static inline function sqrt( f : Float ) {
		return std.Math.sqrt(f);
	}

	/**
	 返回 f 的平方根的倒数, f 的值必须大于 0
	*/
	public static inline function invSqrt( f : Float ) {
		return 1. / sqrt(f);
	}

	/**
	 以弧度为单位计算并返回点 y/x 的角度，该角度从圆的 x 轴（0 点在其上，0 表示圆心）沿逆时针方向测量。

	 返回值介于正 pi 和负 pi 之间。请注意，atan2 的第一个参数始终是 y 坐标

	 e.g: Math.atan2(p1.y - p2.y, p1.x - p2.x);
	*/
	public static inline function atan2( dy : Float, dx : Float ) {
		return std.Math.atan2(dy,dx);
	}

	/**
	 浮点数绝对值
	*/
	public static inline function abs( f : Float ) {
		return f < 0 ? -f : f;
	}

	public static inline function max( a : Float, b : Float ) {
		return a < b ? b : a;
	}

	public static inline function min( a : Float, b : Float ) {
		return a > b ? b : a;
	}

	/**
	* 整数 绝对值
	* @param i
	*/
	public static inline function iabs( i : Int ) {
		return i < 0 ? -i : i;
	}

	public static inline function imax( a : Int, b : Int ) {
		return a < b ? b : a;
	}

	public static inline function imin( a : Int, b : Int ) {
		return a > b ? b : a;
	}

	/**
	* 整数
	* @param v
	* @param min
	* @param max
	*/
	public static inline function iclamp( v : Int, min : Int, max : Int ) {
		return v < min ? min : (v > max ? max : v);
	}

	/**
		Linear interpolation between two values. When k is 0 a is returned, when it's 1, b is returned.

		返回 a 到 b 之间的线性插值. k 的值在 0 ~ 1 之间
	**/
	public inline static function lerp(a:Float, b:Float, k:Float) {
		return a + k * (b - a);
	}

	/**
	返回一个数字需要占多少二进制位??? 例如: 0xF 要 4 bit,而0x1 只 1 bit, 最回最大数字为 32

	* @param v
	*/
	public inline static function bitCount(v:Int) {
		v = v - ((v >> 1) & 0x55555555);
		v = (v & 0x33333333) + ((v >> 2) & 0x33333333);
		return (((v + (v >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;
	}

	public static inline function distanceSq( dx : Float, dy : Float, dz = 0. ) {
		return dx * dx + dy * dy + dz * dz;
	}

	/**
	 距离,如果 dx= a.x-b.x 及 dy= a.y-b.y, 那么这个方法将返回 a 与 b 点之间的距离
	*/
	public static inline function distance( dx : Float, dy : Float, dz = 0. ) {
		return sqrt(distanceSq(dx,dy,dz));
	}

	/**
		Linear interpolation between two colors (ARGB).

		二个颜色数值之间的线性插值, k 在 0 ~ 1 之间.
	**/
	public static function colorLerp( c1 : Int, c2 : Int, k : Float ) {
		var a1 = c1 >>> 24;
		var r1 = (c1 >> 16) & 0xFF;
		var g1 = (c1 >> 8) & 0xFF;
		var b1 = c1 & 0xFF;
		var a2 = c2 >>> 24;
		var r2 = (c2 >> 16) & 0xFF;
		var g2 = (c2 >> 8) & 0xFF;
		var b2 = c2 & 0xFF;
		var a = Std.int(a1 * (1-k) + a2 * k);
		var r = Std.int(r1 * (1-k) + r2 * k);
		var g = Std.int(g1 * (1-k) + g2 * k);
		var b = Std.int(b1 * (1 - k) + b2 * k);
		return (a << 24) | (r << 16) | (g << 8) | b;
	}

	/*
		Clamp an angle into the [-PI,+PI[ range. Can be used to measure the direction between two angles : if Math.angle(A-B) < 0 go left else go right.

		将 angle 限定在 -PI 和 PI 之间....,可以用来测量两个弧度值之间的方向??
	*/
	public static inline function angle( da : Float ) {
		da %= PI * 2;
		if( da > PI ) da -= 2 * PI else if( da <= -PI ) da += 2 * PI;
		return da;
	}

	/**
	* 二个弧度之间的插值, k 在 0 ~ 1.0 之间
	* @param a
	* @param b
	* @param k
	*/
	public static inline function angleLerp( a : Float, b : Float, k : Float ) {
		return a + angle(b - a) * k;
	}

	/**
		Move angle a towards angle b with a max increment. Return the new angle.

		从角度 a 往 b 方向移动 max(弧度), 并返回这个弧度值
	**/
	public static inline function angleMove( a : Float, b : Float, max : Float ) {
		var da = angle(b - a);
		return if( da > -max && da < max ) b else a + (da < 0 ? -max : max);
	}

	public static inline function shuffle<T>( a : Array<T> ) {
		var len = a.length;
		for( i in 0...len ) {
			var x = Std.random(len);
			var y = Std.random(len);
			var tmp = a[x];
			a[x] = a[y];
			a[y] = tmp;
		}
	}

	public inline static function random( max = 1.0 ) {
		return std.Math.random() * max;
	}

	/**
		Returns a signed random between -max and max (both included).

		返回有符号随机值在 -max 与 max 之间(both included)
	**/
	public static function srand( max = 1.0 ) {
		return (std.Math.random() - 0.5) * (max * 2);
	}


	/**
	 * takes an int , masks it and devide so that it safely maps 0...255 to 0...1.0
	 *
	 * 将 0~255 之间的数字 转换到 0~1.0, 例: b2f(127) => 0.4980392156862745
	 * @paramv an int between 0 and 255 will be masked
	 * @return a float between( 0 and 1)
	 */
	public static inline function b2f( v:Int ) :Float {
		return (v&0xFF) * 0.0039215686274509803921568627451;
	}

	/**
	 * takes a float , clamps it and multipy so that it safely maps 0...1 to 0...255.0
	 *
	 * 将 0~1.0 的数转换到 0~255
	 * @param	f a float
	 * @return an int [0...255]
	 */
	public static inline function f2b( v:Float ) : Int {
		return Std.int(clamp(v) * 255.0);
	}

	/**
	 * returns the modulo but always positive, 取模值, 但总是返回正整数
	 */
	public static inline function umod( value : Int, modulo : Int ) {
		var r = value % modulo;
		return r >= 0 ? r : r + modulo;
	}

	/**
	 * returns the modulo but always positive, 取模值, 但总是返回正浮点数
	 */
	public static inline function ufmod( value : Float, modulo : Float ) {
		var r = value % modulo;
		return r >= 0 ? r : r + modulo;
	}

	/**
	 * Convert degrees to radians
	**/
	public static inline function degToRad( deg : Float) {
		return deg * PI / 180.0;
	}

	/**
	 * Convert radians to degrees
	 */
	public static inline function radToDeg( rad : Float) {
		return rad * 180.0 / PI;
	}
}