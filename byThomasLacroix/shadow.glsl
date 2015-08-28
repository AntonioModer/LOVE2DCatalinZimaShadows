number renderTargetSize = 512.0;
vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0);

number GetShadowDistanceH(vec2 TexCoord, Image reduce)
{
	number u = TexCoord.x;
	number v = TexCoord.y;

	u = abs(u - 0.5) * 2.0;
	v = v * 2.0 - 1.0;
	number v0 = v / u;
	v0 = (v0 + 1.0) / 2.0;

	// Horizontal info was stored in the Red component
	return Texel(reduce, vec2((TexCoord.x < 0.5) ? 0.0 : 1.0, v0)).r;
}

number GetShadowDistanceV(vec2 TexCoord, Image reduce)
{
	number u = TexCoord.y;
	number v = TexCoord.x;

	u = abs(u - 0.5) * 2.0;
	v = v * 2.0 - 1.0;
	number v0 = v / u;
	v0 = (v0 + 1.0) / 2.0;
	
	// Vertical info was stored in the Green component
	return Texel(reduce, vec2((TexCoord.y < 0.5) ? 0.0 : 1.0, v0)).g;
}

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
	//texCoord.y = 1-texCoord.y;
	//vec4 pixel = Texel(texture, texCoord);
	
	
	// Distance of this pixel from the center
	number dist = distance(texCoord, vec2(0.5, 0.5));
	
	//apply a ...-pixel bias
	dist -= 0.0 / renderTargetSize;
	
	// Distance stored in the shadow map
	number shadowMapDistance;
	// Coords in [-1,1]
	number nY = 2.0 * (texCoord.y - 0.5);
	number nX = 2.0 * (texCoord.x - 0.5);

	// We use these to determine which quadrant we are in
	if (abs(nY) < abs(nX))
	{
		shadowMapDistance = GetShadowDistanceH(texCoord.xy, texture);
	}
	else
	{
		shadowMapDistance = GetShadowDistanceV(texCoord.xy, texture);
	}
	
	// If distance to this pixel is lower than distance from shadowMap,
	// then we are not in shadow
	number light = dist < shadowMapDistance ? 1.0 : 0.0;
	vec4 result = vec4(light, light, light, light);
	//result *= lightColor;							// set light color
	result.a = 1.0 - light;						// рисует только тени
	
	
	//number x = dist * 2.0;
	//result.a = 1.0 / (2.0 * (x + 0.5)) - 0.2;
	
	//result *= 0.6;									// яркость света (brightness); 0.0 ... 1.0
	//result.a = 1.0 - (dist * 2.0);					// градиент радиальный; (* ...) - это чтобы за текстуру не светил
	
	return result;
}