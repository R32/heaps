package h2d.col;

class Line {

	public var p1 : Point;
	public var p2 : Point;

	public inline function new(p1,p2) {
		this.p1 = p1;
		this.p2 = p2;
	}

	/**
	如果返回值为 0 则表示"点"在"线"上, （以p1作为方向的原点,旋转 p2）返回值为正则"点"在"线"的顺时针方向, 为负则在逆时针方向。

	或者用来同时测量二个点(即二个点组成的线), 如果它们的符号位相同, 则表示这二个点位于 Line 的相同一侧.
	*/
	public inline function side( p : Point ) {
		return (p2.x - p1.x) * (p.y - p1.y) - (p2.y - p1.y) * (p.x - p1.x);
	}

	// 返回 Line 上的一个点, 点p 垂直于 Line 的点.
	public inline function project( p : Point ) {
		var dx = p2.x - p1.x;
		var dy = p2.y - p1.y;
		var k = ((p.x - p1.x) * dx + (p.y - p1.y) * dy) / (dx * dx + dy * dy);
		return new Point(dx * k + p1.x, dy * k + p1.y);
	}

	// 计算二条"线"的相交点, 如果返回 null 则表示二条"线"相互平行
	public inline function intersect( l : Line ) {
		var d = (p1.x - p2.x) * (l.p1.y - l.p2.y) - (p1.y - p2.y) * (l.p1.x - l.p2.x);
		if( hxd.Math.abs(d) < hxd.Math.EPSILON )
			return null;
		var a = p1.x*p2.y - p1.y * p2.x;
		var b = l.p1.x*l.p2.y - l.p1.y*l.p2.x;
		return new Point( (a * (l.p1.x - l.p2.x) - (p1.x - p2.x) * b) / d, (a * (l.p1.y - l.p2.y) - (p1.y - p2.y) * b) / d );
	}

	// 同 intersect, 只是将计算结果赋给 pt 如果成功则返回 true
	public inline function intersectWith( l : Line, pt : Point ) {
		var d = (p1.x - p2.x) * (l.p1.y - l.p2.y) - (p1.y - p2.y) * (l.p1.x - l.p2.x);
		if( hxd.Math.abs(d) < hxd.Math.EPSILON )
			return false;
		var a = p1.x*p2.y - p1.y * p2.x;
		var b = l.p1.x*l.p2.y - l.p1.y*l.p2.x;
		pt.x = (a * (l.p1.x - l.p2.x) - (p1.x - p2.x) * b) / d;
		pt.y = (a * (l.p1.y - l.p2.y) - (p1.y - p2.y) * b) / d;
		return true;
	}

	public inline function distanceSq( p : Point ) {
		var dx = p2.x - p1.x;
		var dy = p2.y - p1.y;
		var k = ((p.x - p1.x) * dx + (p.y - p1.y) * dy) / (dx * dx + dy * dy);
		var mx = dx * k + p1.x - p.x;
		var my = dy * k + p1.y - p.y;
		return mx * mx + my * my;
	}

	public inline function distance( p : Point ) {
		return hxd.Math.sqrt(distanceSq(p));
	}

}