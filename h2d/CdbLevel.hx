package h2d;

#if !castle
"Please compile with -lib castle"
#end

/**

- file: 对应的图片文件名
- stride: TODO: 默认和 size 一样为 16
- size: tile小块的像素大小, 默认为 16
*/
typedef TileSpec = {
	var file(default, never) : String;
	var stride(default, never) : Int;
	var size(default, never) : Int;
}

/**
tile_layer
*/
typedef LayerSpec = {
	var name : String;
	var data : cdb.Types.TileLayer;
}

/**
对应 level sheet 表中的其中一行, 因此实际上除了下边属性还有 index_layer,zone_layer,list_layer 这些如果你定义了的话
- width/height: tile 的数量大小
- props: 对应于castle中level表的 props 字段(这个字段一般由编译器自动填充)
- tileProps: 对应于castle中level表的tileProps 字段
- layers: 为castle中的 tile_layer
*/
typedef LevelSpec = {
	var width : Int;
	var height : Int;
	var props : cdb.Data.LevelProps;
	var tileProps(default, null) : Array<Dynamic>;
	var layers : Array<LayerSpec>;
}

/**
* 所有你在画布上操作设置
*/
class LevelTileset {
	public var stride : Int;
	public var size : Int;
	public var res : hxd.res.Image;
	public var tile : h2d.Tile;
	public var tiles : Array<h2d.Tile>;
	public var objects : Array<LevelObject>;
	public var tilesProps(get, never) : Array<Dynamic>;
	var props :	cdb.Data.TilesetProps;
	var tileBuilder : cdb.TileBuilder;
	public function new() {
	}
	inline function get_tilesProps() return props.props;
	public function getTileBuilder() {
		if( tileBuilder == null )
			tileBuilder = new cdb.TileBuilder(props, stride, tiles.length);
		return tileBuilder;
	}
}

/**
* 参考 castle 编辑器上的 Object Mode
*/
class LevelObject {
	public var tileset : LevelTileset;
	public var id : Int;
	public var x : Int;
	public var y : Int;
	public var width : Int;
	public var height : Int;
	public var props : Dynamic;
	public var tile : h2d.Tile;

	public function new(tset, x, y, w, h) {
		this.tileset = tset;
		this.x = x;
		this.y = y;
		id = x + y * tileset.stride;
		width = w;
		height = h;
		var sz = tileset.size;
		tile = tileset.tile.sub(x * sz, y * sz, width * sz, height * sz);
	}
}

class LevelObjectInstance {
	public var x : Int;
	public var y : Int;
	public var rot : Int;
	public var flip : Bool;
	public var obj : LevelObject;
	public function new() {
	}
}

enum LevelLayerData {
	LTiles( data : Array<Int> );
	LGround( data : Array<Int> );
	LObjects( objects : Array<LevelObjectInstance> );
}

/**
关卡层, 即castle中tile_layer的层
*/
class LevelLayer {

	/**
		Which level this layer belongs to
		图层属于哪一个 CdbLevel
	**/
	public var level : CdbLevel;

	/**
		The name of the layer, as it was created in CDB
		图层的名字, 和 castle 中创建的一样.
	**/
	public var name : String;

	/**
		CdbLevel extends Layers: this index will tell in which sprite layer this LevelLayer content is added to.

		图层位于其数组中的索引
	**/
	public var layerIndex(default,null) : Int;

	/**
		The raw data of the layer. You can read it or modify it then set needRedraw=true to update it on screen.

		图层的 raw 数据形式, 你可以设 needRedraw=true, 即可以在屏幕上看到这个图层
	**/
	public var data : LevelLayerData;

	/**
		The tileset this layer is using to display its graphics
	**/
	public var tileset : LevelTileset;

	/**
		If the layer needs to be redrawn, it's set to true.

		如果这个层需要画到屏幕需要设置为 true
	**/
	public var needRedraw = true;

	/**
		Allows to add objects on the same layerIndex that can behind or in front of the
	**/
	public var objectsBehind(default, set) : Bool;

	/**
		One or several tile groups that will be used to display the layer
	**/
	public var contents : Array<h2d.TileGroup>;

	/**
		Alias to the first element of contents
	**/
	public var content(get, never) : h2d.TileGroup;

	public function new(level) {
		this.level = level;
	}

	inline function get_content() {
		return contents[0];
	}

	/**
		Entirely removes this layer from the level.
	**/
	public function remove() {
		for( c in contents )
			c.remove();
		contents = [];
		level.layers.remove(this);
		@:privateAccess level.layersMap.remove(name);
	}

	/**
		Returns the data for the given CDB per-tile property based on the data of the current layer.
		For instance if you have a "collide" per-tile property set for several of your objects or tiles,
		then calling buildIntProperty("collide") will return you with the collide data for the given layer.
		In case of objects, if several objects overlaps, the greatest property value overwrites the lowest.
	**/
	public function buildIntProperty( name : String ) {
		var tprops = [for( p in tileset.tilesProps ) p == null ? 0 : Reflect.field(p, name)];
		var out = [for( i in 0...level.width * level.height ) 0];
		switch( data ) {
		case LTiles(data), LGround(data):
			for( i in 0...level.width * level.height ) {
				var t = data[i];
				if( t == 0 ) continue;
				out[i] = tprops[t - 1];
			}
		case LObjects(objects):
			for( o in objects ) {
				var ox = Std.int(o.x / tileset.size);
				var oy = Std.int(o.y / tileset.size);
				for( dy in 0...o.obj.height )
					for( dx in 0...o.obj.width ) {
						var idx = ox + dx + (oy + dy) * level.width;
						var cur = tprops[o.obj.id + dx + dy * tileset.stride];
						if( cur > out[idx] )
							out[idx] = cur;
					}
			}
		}
		return out;
	}

	public function buildStringProperty( name : String ) {
		var tprops = [for( p in tileset.tilesProps ) p == null ? null : Reflect.field(p, name)];
		var out : Array<String> = [for( i in 0...level.width * level.height ) null];
		switch( data ) {
		case LTiles(data), LGround(data):
			for( i in 0...level.width * level.height ) {
				var t = data[i];
				if( t == 0 ) continue;
				out[i] = tprops[t - 1];
			}
		case LObjects(objects):
			for( o in objects ) {
				var ox = Std.int(o.x / tileset.size);
				var oy = Std.int(o.y / tileset.size);
				for( dy in 0...o.obj.height )
					for( dx in 0...o.obj.width ) {
						var idx = ox + dx + (oy + dy) * level.width;
						var cur = tprops[o.obj.id + dx + dy * tileset.stride];
						if( cur != null )
							out[idx] = cur;
					}
			}
		}
		return out;
	}

	function set_objectsBehind(v) {
		if( v == objectsBehind )
			return v;
		if( v && !data.match(LObjects(_)) )
			throw "Can only set objectsBehind for 'Objects' Layer Mode";
		needRedraw = true;
		return objectsBehind = v;
	}
}

/**
	CdbLevel will decode and display a level created with the CastleDB level editor.
	See http://castledb.org for more details.
**/
class CdbLevel extends Layers {

	/**
	* 宽和高都将表示 tile 的数量
	*/
	public var width(default, null) : Int;
	public var height(default, null) : Int;

	/**
	* 对应 castle 中 level sheet(关卡表)中的一行数据
	*/
	public var level(default, null) : LevelSpec;

	/**
	* 包含所有 tile_layer
	*/
	public var layers : Array<LevelLayer>;

	/**
	* 包含所有你在画布(例如某一个png图片)上的操作, 例如你设置其中的几个小块(tile)为border 或 object
	*/
	var tilesets : Map<String, LevelTileset>;

	/**
	* 包含所有 tile_layer
	*/
	var layersMap : Map<String, LevelLayer>;
	var levelsProps : cdb.Data.LevelsProps;

	/**
	* e.g `new CdbLevel(Data.levelData, 0, s2d);`
	* @param allLevels :level sheet(关卡表)
	* @param index : 其位于 level_sheet 中的第几行数据(默认第一行为 0)
	* @param parent : 将要添加到的哪一个父图层(Layers)
	*/
	public function new(allLevels:cdb.Types.Index<Dynamic>,index:Int,?parent) {
		super(parent);
		levelsProps = @:privateAccess allLevels.sheet.props.level;
		level = allLevels.all[index];
		width = level.width;
		height = level.height;
		tilesets = new Map();
		layersMap = new Map();
		layers = [];
		for( ldat in level.layers ) {
			var l = loadLayer(ldat);
			if( l != null ) {
				@:privateAccess l.layerIndex = layers.length;
				layers.push(l);
				layersMap.set(l.name, l);

				var content = new h2d.TileGroup(l.tileset.tile);
				add(content, l.layerIndex);
				l.contents = [content];
			}
		}
	}

	public function getLevelLayer( name : String ) : LevelLayer {
		return layersMap.get(name);
	}

	public function buildIntProperty( name : String ) {
		var collide = null;
		for( l in layers ) {
			var layer = l.buildIntProperty(name);
			if( collide == null )
				collide = layer;
			else
				for( i in 0...width	* height ) {
					var v = layer[i];
					if( v != 0 && v > collide[i] ) collide[i] = v;
				}
		}
		if( collide == null ) collide = [for( i in 0...width * height ) 0];
		return collide;
	}

	public function buildStringProperty( name : String ) {
		var collide = null;
		for( l in layers ) {
			var layer = l.buildStringProperty(name);
			if( collide == null )
				collide = layer;
			else
				for( i in 0...width	* height ) {
					var v = layer[i];
					if( v != null ) collide[i] = v;
				}
		}
		if( collide == null ) collide = [for( i in 0...width * height ) null];
		return collide;
	}

	public function getTileset( file : String ) : LevelTileset {
		return tilesets.get(file);
	}

	function redrawLayer( l : LevelLayer ) {
		for( c in l.contents )
			c.clear();
		l.needRedraw = false;
		var pos = 0;
		switch( l.data ) {
		case LTiles(data), LGround(data):
			var size = l.tileset.size;
			var tiles = l.tileset.tiles;
			var i = 0;
			var content = l.contents[pos++];
			for( y in 0...height )
				for( x in 0...width ) {
					var t = data[i++];
					if( t == 0 ) continue;
					content.add(x * size, y * size, tiles[t - 1]);
				}
			if( l.data.match(LGround(_)) ) {
				var b = l.tileset.getTileBuilder();
				var grounds = b.buildGrounds(data, width);
				var glen = grounds.length;
				var i = 0;
				while( i < glen ) {
					var x = grounds[i++];
					var y = grounds[i++];
					var t = grounds[i++];
					content.add(x * size, y * size, tiles[t]);
				}
			}
		case LObjects(objects):
			if( l.objectsBehind ) {
				var pos = 0;
				var byY = [];
				var curY = -1;
				var content = null;
				for( o in objects ) {
					var baseY = o.y + o.obj.tile.height;
					if( baseY != curY ) {
						curY = baseY;
						content = byY[baseY];
						if( content == null ) {
							content = l.contents[pos++];
							if( content == null ) {
								content = new h2d.TileGroup(l.tileset.tile);
								add(content, l.layerIndex);
								l.contents.push(content);
							}
							content.y = baseY;
							byY[baseY] = content;
						}
					}
					content.add(o.x, o.y - baseY, o.obj.tile);
				}
			} else {
				var content = l.contents[pos++];
				for( o in objects )
					content.add(o.x, o.y, o.obj.tile);
			}
		}
		// clean extra lines
		while( pos > 0 && l.contents[pos] != null )
			l.contents.pop().remove();
	}

	function loadTileset( ldat : TileSpec ) : LevelTileset {
		var t = new LevelTileset();
		t.size = ldat.size;
		t.stride = ldat.stride;
		t.res = hxd.res.Loader.currentInstance.load(ldat.file).toImage();
		t.tile = t.res.toTile();
		t.tiles = t.tile.gridFlatten(t.size);
		t.objects = [];
		var tprops = Reflect.field(levelsProps.tileSets, ldat.file);
		@:privateAccess t.props = tprops;
		if( tprops != null ) {
			var hasBorder = false;
			for( s in tprops.sets )
				switch( s.t ) {
				case Object:
					var o = new LevelObject(t, s.x, s.y, s.w, s.h);
					t.objects[o.id] = o;
				case Group:
					// TODO : save props
				case Ground, Border, Tile:
					// nothing
				}
		}
		return t;
	}

	function resolveTileset( tdat : TileSpec ) {
		var t = tilesets.get(tdat.file);
		if( t == null ) {
			t = loadTileset(tdat);
			if( t == null )
				return null;
			tilesets.set(tdat.file, t);
		}
		if( t.stride != tdat.stride || t.size != tdat.size )
			throw "Tileset " + tdat.file+" is used with different stride/size";
		return t;
	}

	function loadLayer( ldat : LayerSpec ) : LevelLayer {
		var t = resolveTileset(ldat.data);
		if( t == null )
			return null;
		var l = new LevelLayer(this);
		l.name = ldat.name;
		l.tileset = t;
		var data = ldat.data.data.decode();
		var lprops = null;
		for( lp in level.props.layers )
			if( lp.l == l.name ) {
				lprops = lp.p;
				break;
			}
		var mode : cdb.Data.LayerMode = lprops != null && lprops.mode != null ? lprops.mode : Tiles;
		switch( mode ) {
		case Tiles:
			l.data = LTiles(data);
		case Ground:
			l.data = LGround(data);
		case Objects:
			var objs = [];
			var i = 1;
			var len = data.length;
			while( i < len ) {
				var x = data[i++];
				var y = data[i++];
				var t = data[i++];
				var e = new LevelObjectInstance();
				e.x = x & 0x7FFF;
				e.y = y & 0x7FFF;
				e.rot = (x >> 15) | ((y >> 15) << 1);
				e.flip = (t >> 15) != 0;
				t &= 0x7FFF;
				e.obj = l.tileset.objects[t];
				if( e.obj == null ) {
					// create new 1x1 object
					var o = new LevelObject(l.tileset, t%l.tileset.stride, Std.int(t/l.tileset.stride), 1, 1);
					e.obj = l.tileset.objects[t] = o;
				}
				objs.push(e);
			}
			l.data = LObjects(objs);
			l.objectsBehind = true;
		}
		return l;
	}

	public function redraw() {
		for( l in layers )
			if( l.needRedraw )
				redrawLayer(l);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		for( l in layers ) {
			if( l.needRedraw )
				redrawLayer(l);
			if( l.objectsBehind )
				ysort(l.layerIndex);
		}
	}

}