number renderTargetSize = 512;

number GetShadowDistanceH(vec2 TexCoord, Image texture)
{
	number u = TexCoord.x;
	number v = TexCoord.y;

	u = abs(u-0.5) * 2;
	v = v * 2 - 1;
	number v0 = v/u;
	v0 = (v0 + 1) / 2;

	vec2 newCoords = vec2(TexCoord.x,v0);
	//horizontal info was stored in the Red component
	return Texel(texture, newCoords).r;
}
 
number GetShadowDistanceV(vec2 TexCoord, Image texture)
{
	number u = TexCoord.y;
	number v = TexCoord.x;

	u = abs(u-0.5) * 2;
	v = v * 2 - 1;
	number v0 = v/u;
	v0 = (v0 + 1) / 2;

	vec2 newCoords = vec2(TexCoord.y,v0);
	//vertical info was stored in the Green component
	return Texel(texture, newCoords).g;
}

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
	//texCoord.y = 1-texCoord.y;
	vec4 pixel = Texel(texture, texCoord);
	
	// distance of this pixel from the center
	number distance = length(texCoord - 0.5);
	distance *= renderTargetSize;
	 
	//apply a 2-pixel bias
	distance -=2;
	 
	//distance stored in the shadow map
	number shadowMapDistance;
	//coords in [-1,1]
	number nY = 2.0*( texCoord.y - 0.5);
	number nX = 2.0*( texCoord.x - 0.5);
	 
	//we use these to determine which quadrant we are in
	if(abs(nY)<abs(nX))
	{
		shadowMapDistance = GetShadowDistanceH(texCoord, texture);
	}
	else
	{
		shadowMapDistance = GetShadowDistanceV(texCoord, texture);
	}
	 
	//if distance to this pixel is lower than distance from shadowMap,
	//then we are not in shadow
	number light = distance < shadowMapDistance ? 1:0;
	vec4 result = vec4(light, light, light, light);
	result.b = length(texCoord - 0.5);
	result.a = 1;
	
	return result;
}