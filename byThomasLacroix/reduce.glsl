number renderTargetSize = 256.0;													// чем меньше, тем больше ФПС и больше артефактов в тенях

vec2 Reduce(vec2 TexCoord, Image texture)
{
	number y = TexCoord.y;
	vec2 max = vec2(1.0, 1.0);

	if (TexCoord.x == 0.5)
	{
		for (number i = renderTargetSize / 2.0; i > 0.0; --i)
		{
			vec2 pos = vec2(i / renderTargetSize, y);
			vec2 color = Texel(texture, pos).rg;
			max = min(color, max);
			
			if (max.x != 1.0 && max.y != 1.0)
				return max;
		}
		return max;
	}
	else
	{
		for (number i = renderTargetSize / 2.0; i < renderTargetSize; ++i)
		{
			vec2 pos = vec2(i / renderTargetSize, y);
			vec2 color = Texel(texture, pos).rg;
			max = min(color, max);
			
			if (max.x != 1.0 && max.y != 1.0)
				return max;
		}
		return max;
	}
}

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
	//texCoord.y = 1-texCoord.y;
	//vec4 pixel = Texel(texture, texCoord);
	
	return vec4(Reduce(vec2(screenCoord.x, texCoord.y), texture), 0.0, 1.0);		// source
}