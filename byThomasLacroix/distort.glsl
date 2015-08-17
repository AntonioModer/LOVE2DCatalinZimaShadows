number BlackOrDistance(vec2 TexCoord, Image texture)
{
	// Calcule la distance
	number dist = distance(TexCoord.xy, vec2(0.5, 0.5));

	// Transforme tout en noir
	if (Texel(texture, TexCoord.xy).a == 1.0)
		return dist;
	else
		return 1.0;
}

vec4 Distort(vec2 TexCoord, Image texture)
{
	// Translate u and v into [-1 , 1] domain
	number u0 = TexCoord.x * 2.0 - 1.0;
	number v0 = TexCoord.y * 2.0 - 1.0;
 
	// Then, as u0 approaches 0 (the center), v should also approach 0
	v0 = v0 * abs(u0);
	
	// Convert back from [-1,1] domain to [0,1] domain
	v0 = (v0 + 1.0) / 2.0;
	
	// We now have the coordinates for reading from the initial image
	vec2 newCoords = vec2(TexCoord.x, v0);
 
	// Read for both horizontal and vertical direction and store them in separate channels
	number horizontal = BlackOrDistance(newCoords.xy, texture);
	number vertical = BlackOrDistance(newCoords.yx, texture);

	// Change la couleur
	return vec4(horizontal, vertical, 0.0, 1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
	//texCoord.y = 1-texCoord.y;
	//vec4 pixel = Texel(texture, texCoord);
	
	return Distort(texCoord, texture);
}