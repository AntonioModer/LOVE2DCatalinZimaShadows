vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
	//texCoord.y = 1-texCoord.y;
	vec4 pixel = Texel(texture, texCoord);								// This is the current pixel color
	
	
	// translate u and v into [-1 , 1] domain
	number u0 = texCoord.x * 2.0 - 1.0;
	number v0 = texCoord.y * 2.0 - 1.0;

	// then, as u0 approaches 0 (the center), v should also approach 0 
	v0 = v0 * abs(u0);

	//convert back from [-1,1] domain to [0,1] domain
	v0 = (v0 + 1.0) / 2.0;

	// we now have the coordinates for reading from the initial image
	vec2 newCoord = vec2(texCoord.x, v0);

	// read for both horizontal and vertical direction and store them in separate channels
	number horizontal = Texel(texture, newCoord).r;
	number vertical = Texel(texture, newCoord.yx).r;
	
	return vec4(horizontal, vertical, 0, 1);
}