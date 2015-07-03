package h3d.shader;
/**
	通常用于忽略背影颜色, 也就是忽略图片的底色以达到透明图片的效果.	
*/
class ColorKey extends hxsl.Shader {

	static var SRC = {
		@param var colorKey : Vec4;
		var textureColor : Vec4;

		function fragment() {
			var cdiff = textureColor - colorKey;
			if( cdiff.dot(cdiff) < 0.00001 ) discard;
		}
	}

	public function new( v = 0 ) {
		super();
		colorKey.setColor(v);
	}

}