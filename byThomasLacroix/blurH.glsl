// Thanks to http://www.alpha-arts.net/blog/articles/view/30/shader-de-blur

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
	//texCoord.y = 1-texCoord.y;
	vec4 pixel = Texel(texture, texCoord);
	
	vec2 off = vec2(0.008, 0.0);

	return pixel * (
		Texel(texture, texCoord.xy + off * 1.0)  * 0.06 + 
		Texel(texture, texCoord.xy + off * 0.75) * 0.09 +
		Texel(texture, texCoord.xy + off * 0.5)  * 0.12 +
		Texel(texture, texCoord.xy + off * 0.25) * 0.15 +
		Texel(texture, texCoord.xy) * 0.16 +
		Texel(texture, texCoord.xy - off * 1.0)  * 0.06 +
		Texel(texture, texCoord.xy - off * 0.75) * 0.09 +
		Texel(texture, texCoord.xy - off * 0.5)  * 0.12 +
		Texel(texture, texCoord.xy - off * 0.25) * 0.15 );	
}