package hxd.res;

/**
compressSounds: 是否压缩 WAV 音乐文件。

compressAsMp3: true 则将 wav 压缩成 mp3, false 则压缩成 ogg. 注: 如果不存在 haxelib stb_ogg_sound 库的话, 则还是压成 mp3。

tmpDir: 指定 lame 输出的临时文件夹. 默认为 资源目录下的 `.tmp`

fontsChars: 默认为: `Charset.DEFAULT_CHARS.split("-").join("\\-")`, 自定义时注意处理 `-` 符号的转义.
*/
typedef EmbedOptions = {
	?compressSounds : Bool,
	?compressAsMp3 : Bool,
	?tmpDir : String,
	?fontsChars : String,
}