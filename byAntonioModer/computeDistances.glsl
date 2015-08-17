vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord)
{
	//texCoord.y = 1-texCoord.y;
	vec4 pixel = Texel(texture, texCoord);								// This is the current pixel color
	
	// distance(texCoord.xy, vec2(0.5, 0.5));
	number dist = pixel.a > 0.3 ? length(texCoord - 0.5) : 1.0;		// compute distance from center
	dist *= 2;														
	
	return vec4(pixel.r + dist, 0, 0, 1);										// save it to the Red channel
}