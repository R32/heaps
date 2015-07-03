package h2d;

@:allow(h2d)
class Tile {

	var innerTex : h3d.mat.Texture;

	var u : Float;
	var v : Float;
	var u2 : Float;
	var v2 : Float;

	/**
	默认的 dx dy 为 0  即左上角, 右下角为 -width,-height，因此当 dx,dy 都为正数时，坐标是在 0 左上方。
	*/
	public var dx : Int;
	public var dy : Int;
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var width(default,null) : Int;
	public var height(default,null) : Int;

	function new(tex : h3d.mat.Texture, x : Int, y : Int, w : Int, h : Int, dx=0, dy=0) {
		this.innerTex = tex;
		this.x = x;
		this.y = y;
		this.width = w;
		this.height = h;
		this.dx = dx;
		this.dy = dy;
		if( tex != null ) setTexture(tex);
	}

	public inline function getTexture():h3d.mat.Texture {
		return innerTex;
	}

	public function isDisposed() {
		return innerTex == null || innerTex.isDisposed();
	}

	function setTexture(tex : h3d.mat.Texture) {
		this.innerTex = tex;
		if( tex != null ) {
			this.u = x / tex.width;
			this.v = y / tex.height;
			this.u2 = (x + width) / tex.width;
			this.v2 = (y + height) / tex.height;
		}
	}

	public inline function switchTexture( t : Tile ) {
		setTexture(t.innerTex);
	}

	/**
	* 实际上你应该使用某些工具来做这个更为方便, 例如 castleDb。
	*/
	public function sub( x : Int, y : Int, w : Int, h : Int, dx = 0, dy = 0 ) : Tile {
		return new Tile(innerTex, this.x + x, this.y + y, w, h, dx, dy);
	}

	/**
	* 返回一个新的Tile, 支点(pivot)位于中心点,移动坐标或旋转都将以支点为基准
	*/
	public function center():Tile {
		return sub(0, 0, width, height, -(width>>1), -(height>>1));
	}

	/**
	 设置 dx/dy 的位置，默认为 0.5/0.5 即 tile 的中心.
	*/
	public inline function setCenterRatio(?px:Float=0.5, ?py:Float=0.5) : Void {
		dx = -Std.int(px*width);
		dy = -Std.int(py*height);
	}

	/**
	* Y轴水平翻转(左右), 翻转之后 dx 的值将会被修改(表现为沿 dx 轴翻转)
	*/
	public function flipX() : Void {
		var tmp = u; u = u2; u2 = tmp;
		dx = -dx - width;
	}

	/**
	* X轴水平翻转(上下), 翻转之后 dy 的值将会改动(表现为沿 dy 轴翻转)
	*/
	public function flipY() : Void {
		var tmp = v; v = v2; v2 = tmp;
		dy = -dy - height;
	}

	/**
	 设置 x y 坐标, 需要注意的是 tile 的 x, y 和其它 sprite 的效果并不一样的
	 是用来微调当前 tile 位于 texture 中的位置，而非相对于显示列表的父元素
	*/
	public function setPos(x : Int, y : Int) : Void {
		this.x = x;
		this.y = y;
		var tex = innerTex;
		if( tex != null ) {
			u = x / tex.width;
			v = y / tex.height;
			u2 = (x + width) / tex.width;
			v2 = (y + height) / tex.height;
		}
	}

	/**
	调整尺寸(当前 tile 位于 texture 的大小), 仅调整右下角的 uv 值, 因此不会引起缩放
	*/
	public function setSize(w : Int, h : Int) : Void {
		this.width = w;
		this.height = h;
		var tex = innerTex;
		if( tex != null ) {
			u2 = (x + w) / tex.width;
			v2 = (y + h) / tex.height;
		}
	}

	/**
	 缩放到指定大小。
	*/
	public function scaleToSize( w : Int, h : Int ) : Void {
		this.width = w;
		this.height = h;
	}

	/**
	 更改其位于 texture 中的位置从而产生一种 scroll 的效果

	 (filter.Displacement 滤镜特效也可能会用到它, 参看 samples/Filters.hx
	 使用这种特效时需要禁止将这个 tile 作为 sprite 展现(即使是 clone 的都不行, 除非通过 bitmapData),
	 因为它会导致将会滚动出边界而使这个特效失去效果.)
	*/
	public function scrollDiscrete( dx : Float, dy : Float ) : Void {
		var tex = innerTex;
		u += dx / tex.width;
		v -= dy / tex.height;
		u2 += dx / tex.width;
		v2 -= dy / tex.height;
		x = Std.int(u * tex.width);
		y = Std.int(v * tex.height);
	}

	public function dispose() : Void {
		if( innerTex != null ) innerTex.dispose();
		innerTex = null;
	}

	public function clone() : Tile {
		var t = new Tile(null, x, y, width, height, dx, dy);
		t.innerTex = innerTex;
		t.u = u;
		t.u2 = u2;
		t.v = v;
		t.v2 = v2;
		return t;
	}

	/**
		Split horizontaly or verticaly the number of given frames
		根据 frames 的值分割，默认为水平方向(即 vertical = false)。
	**/
	public function split( frames : Int = 0, vertical = false ) : Array<Tile> {
		var tl = [];
		if( vertical ) {
			if( frames == 0 )
				frames = Std.int(height / width);
			var stride = Std.int(height / frames);
			for( i in 0...frames )
				tl.push(sub(0, i * stride, width, stride));
		} else {
			if( frames == 0 )
				frames = Std.int(width / height);
			var stride = Std.int(width / frames);
			for( i in 0...frames )
				tl.push(sub(i * stride, 0, stride, height));
		}
		return tl;
	}

	/**
		Split the tile into a list of tiles of Size x Size pixels.
		Unlike grid which is X/Y ordered, gridFlatten returns a single dimensional array ordered in Y/X.
		根据指定的 size 值将 tile 分割成一个 "横条" 的一唯数组。
	**/
	public function gridFlatten( size : Int, dx = 0, dy = 0 ) : Array<Tile> {
		return [for( y in 0...Std.int(height / size) ) for( x in 0...Std.int(width / size) ) sub(x * size, y * size, size, size, dx, dy)];
	}

	/**
		Split the tile into a list of tiles of Size x Size pixels.
		根据指定的 size 将 tile 分割成 "坚条" 的二唯数组, 每一个坚条是一个 tile 数组。
	**/
	public function grid( size : Int, dx = 0, dy = 0 ) : Array<Array<Tile>> {
		return [for( x in 0...Std.int(width / size) ) [for( y in 0...Std.int(height / size) ) sub(x * size, y * size, size, size, dx, dy)]];
	}

	public function toString() : String {
		return "Tile(" + x + "," + y + "," + width + "x" + height + (dx != 0 || dy != 0 ? "," + dx + ":" + dy:"") + ")";
	}

	function upload( bmp:hxd.BitmapData ) : Void {
		var w = innerTex.width;
		var h = innerTex.height;
		#if flash
		if( w != bmp.width || h != bmp.height ) {
			var bmp2 = new flash.display.BitmapData(w, h, true, 0);
			var p0 = new flash.geom.Point(0, 0);
			var bmp = bmp.toNative();
			bmp2.copyPixels(bmp, bmp.rect, p0, bmp, p0, true);
			innerTex.uploadBitmap(hxd.BitmapData.fromNative(bmp2));
			bmp2.dispose();
		} else
		#end
		innerTex.uploadBitmap(bmp);
	}


	public static function fromColor( color : Int, ?width = 1, ?height = 1, ?alpha = 1., ?allocPos : h3d.impl.AllocPos ) : Tile {
		var t = new Tile(h3d.mat.Texture.fromColor(color,alpha,allocPos),0,0,1,1);
		// scale to size
		t.width = width;
		t.height = height;
		return t;
	}

	public static function fromBitmap( bmp : hxd.BitmapData, ?allocPos : h3d.impl.AllocPos ) : Tile {
		var tex = h3d.mat.Texture.fromBitmap(bmp, allocPos);
		return new Tile(tex, 0, 0, bmp.width, bmp.height);
	}

	/**
	 这个方法比上边的 gird 要更智能一些, 通过指定的 width/height 自动裁剪 bmp 上各个 tile 到 texture,
	 将自动通过 isEmpty 来判断 tile 的边界及空块
	*/
	public static function autoCut( bmp : hxd.BitmapData, width : Int, ?height : Int, ?allocPos : h3d.impl.AllocPos ) {
		#if js
		bmp.lock();
		#end
		if( height == null ) height = width;
		var colorBG = bmp.getPixel(bmp.width - 1, bmp.height - 1);
		var tl = new Array();
		var w = 1, h = 1;
		while( w < bmp.width )
			w <<= 1;
		while( h < bmp.height )
			h <<= 1;
		var tex = new h3d.mat.Texture(w, h, allocPos);
		for( y in 0...Std.int(bmp.height / height) ) {
			var a = [];
			tl[y] = a;
			for( x in 0...Std.int(bmp.width / width) ) {
				var sz = isEmpty(bmp, x * width, y * height, width, height, colorBG);
				if( sz == null )
					break;
				a.push(new Tile(tex,x*width+sz.dx, y*height+sz.dy, sz.w, sz.h, sz.dx, sz.dy));
			}
		}
		#if js
		bmp.unlock();
		#end
		var main = new Tile(tex, 0, 0, bmp.width, bmp.height);
		main.upload(bmp);
		return { main : main, tiles : tl };
	}

	public static function fromTexture( t : h3d.mat.Texture ) : Tile {
		return new Tile(t, 0, 0, t.width, t.height);
	}

	public static function fromPixels( pixels : hxd.Pixels, ?allocPos : h3d.impl.AllocPos ) : Tile {
		var pix2 = pixels.makeSquare(true);
		var t = h3d.mat.Texture.fromPixels(pix2);
		if( pix2 != pixels ) pix2.dispose();
		return new Tile(t, 0, 0, pixels.width, pixels.height);
	}

	static function isEmpty( b : hxd.BitmapData, px : Int, py : Int, width : Int, height : Int, bg : Int ) {
		var empty = true;
		var xmin = width, ymin = height, xmax = 0, ymax = 0;
		for( x in 0...width )
			for( y in 0...height ) {
				var color : Int = b.getPixel(x + px, y + py);
				if( color & 0xFF000000 == 0 ) {
					if( color != 0 ) b.setPixel(x + px, y + py, 0);
					continue;
				}
				if( color != bg ) {
					empty = false;
					if( x < xmin ) xmin = x;
					if( y < ymin ) ymin = y;
					if( x > xmax ) xmax = x;
					if( y > ymax ) ymax = y;
				}
				if( color == bg && color != 0 )
					b.setPixel(x + px, y + py, 0);
			}
		return empty ? null : { dx : xmin, dy : ymin, w : xmax - xmin + 1, h : ymax - ymin + 1 };
	}

}
