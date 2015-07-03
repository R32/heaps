package h2d;

/**
图层, 通常使用 Int 值来表示图层, 值越大将显示在最顶层
*/
class Layers extends Sprite {

	// the per-layer insert position
	var layersIndexes : Array<Int>;
	var layerCount : Int;

	public function new(?parent) {
		super(parent);
		layersIndexes = [];
		layerCount = 0;
	}

	/**
	 将子元素添加到 0 层
	*/
	override function addChild(s) {
		addChildAt(s, 0);
	}

	/**
	通常这个方法用于添加另一个图层,通常 layer 指定为非 0 值
	*/
	public inline function add(s, layer) {
		return addChildAt(s, layer);
	}

	/**
	请注意这个方法不同于 Sprite::addChildAt, layer 指的是图层, 默认为 0(addChild),

	如果 addChild 一个 s1, 然后再 addChild(s2,0), 其实是将 s2 也插入到 0 层中去,
	也就是说 s1,和 s2 对于同一图层 0, s2 在 s1 的后边.

	所以这个类的 getChildAt 值不正确..而是因该使用 getLayer, 来获得同一图层上的元素.

	可以使用 under/over 来更改 sprite 的次序.

	using layer index instead of depth number in addChildAt etc.
	*/
	override function addChildAt( s : Sprite, layer : Int ) {
		if( s.parent == this ) {
			var old = s.allocated;
			s.allocated = false;
			removeChild(s);
			s.allocated = old;
		}
		// new layer
		while( layer >= layerCount )
			layersIndexes[layerCount++] = children.length;
		super.addChildAt(s,layersIndexes[layer]);
		for( i in layer...layerCount )
			layersIndexes[i]++;
	}

	override function removeChild( s : Sprite ) {
		for( i in 0...children.length ) {
			if( children[i] == s ) {
				children.splice(i, 1);
				if( s.allocated ) s.onRemove();
				s.parent = null;
				var k = layerCount - 1;
				while( k >= 0 && layersIndexes[k] > i ) {
					layersIndexes[k]--;
					k--;
				}
				break;
			}
		}
	}
	/**
	将 sprite 放置到 **同一图层** 的最底层.
	*/
	public function under( s : Sprite ) {
		for( i in 0...children.length )
			if( children[i] == s ) {
				var pos = 0;
				for( l in layersIndexes )
					if( l > i )
						break;
					else
						pos = l;
				var p = i;
				while( p > pos ) {
					children[p] = children[p - 1];
					p--;
				}
				children[pos] = s;
				break;
			}
	}

	/**
	将 sprite 放置到 **同一图层** 的最顶层.
	*/
	public function over( s : Sprite ) {
		for( i in 0...children.length )
			if( children[i] == s ) {
				for( l in layersIndexes )
					if( l > i ) {
						for( p in i...l-1 )
							children[p] = children[p + 1];
						children[l - 1] = s;
						break;
					}
				break;
			}
	}

	/**
	得到指定图层之中的所有 sprite 元素的迭代器
	*/
	public function getLayer( layer : Int ) : Iterator<Sprite> {
		var a;
		if( layer >= layerCount )
			a = [];
		else {
			var start = layer == 0 ? 0 : layersIndexes[layer - 1];
			var max = layersIndexes[layer];
			a = children.slice(start, max);
		}
		return new hxd.impl.ArrayIterator(a);
	}

	function drawLayer( ctx : RenderContext, layer : Int ) {
		if( layer >= layerCount )
			return;
		var old = ctx.globalAlpha;
		ctx.globalAlpha *= alpha;
		var start = layer == 0 ? 0 : layersIndexes[layer - 1];
		var max = layersIndexes[layer];
		if( ctx.front2back ) {
			for( i in start...max ) children[max - 1 - i].drawRec(ctx);
		} else {
			for( i in start...max ) children[i].drawRec(ctx);
		}
		ctx.globalAlpha = old;
	}

	/**
	 针对指定图层(layer),根据 坐标 y 值重新排序, y 值大的将显示在显示列表顶层
	*/
	public function ysort( layer : Int ) {
		if( layer >= layerCount ) return;
		var start = layer == 0 ? 0 : layersIndexes[layer - 1];
		var max = layersIndexes[layer];
		if( start == max )
			return;
		var pos = start;
		var ymax = children[pos++].y;
		while( pos < max ) {
			var c = children[pos];
			if( c.y < ymax ) {
				var p = pos - 1;
				while( p >= start ) {
					var c2 = children[p];
					if( c.y >= c2.y ) break;
					children[p + 1] = c2;
					p--;
				}
				children[p + 1] = c;
			} else
				ymax = c.y;
			pos++;
		}
	}


}