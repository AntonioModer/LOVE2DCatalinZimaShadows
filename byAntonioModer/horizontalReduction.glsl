vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord)
{
	vec4 pixel4 = Texel(texture, texCoord);
	vec2 pixel2 = vec2(pixel4.r, pixel4.g);
	vec2 texDimension = vec2(1.0 / 512.0, 1.0 / 512.0);
	vec4 pixelR4 = Texel(texture, texCoord + vec2(texDimension.x, 0));
	vec2 pixelR2 = vec2(pixelR4.x, pixelR4.y);
	vec2 result = min(pixel2, pixelR2);
	
	return vec4(result.x, result.y, 0, 1);
}