uniform float timer;

// I use this oneliner that I found on the internet somewhere 
// - Some guy on the Internet
float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 Process(vec4 color)
{
    const float threeSixty = 360 * 0.01745329;
	const float oneEighty = 180 * 0.01745329;
	const float flowSpeed = 90.0 * 0.01745329;
	const float dropTime = 0.5678910111213141516;
	const float dropDelay = 6.5;
    const float timeOffsetMultiplier = 6.5;
    const float distMul = 1.0/1600.0;

	float T = timer;
	vec2 texCoord = gl_TexCoord[0].st;
    ivec2 texSize1 = textureSize(tex, 0);
    ivec2 texSize2 = textureSize(rippleTex, 0);
    vec2 tCoord = texCoord / (vec2(texSize2) / vec2(texSize1));
    vec4 tcol = texture(rippleTex, tCoord);
	
    float tCoordOffset = rand(vec2(floor(tCoord.y), floor(tCoord.x))) * dropDelay;
	T += tcol.b * timeOffsetMultiplier; // Offset time with blue channel
	T += tCoordOffset;                  // Shift offset a bit for every tile, so tiles don't resemble each other
                                        // Because of this behaviour the input texture cannot have elements that wrap over the edges!
    
	float dt = floor(T / dropDelay) * dropDelay;
	float dropPhase = clamp( (T - dt) / dropTime, 0.0f, 1.0f);
	float intensity = max(0, tcol.a * ( sin((dropPhase * oneEighty) + (tcol.r * flowSpeed)) ));

#if defined(opacity)
    intensity *= opacity;
#endif

    // Fade to 1600 world units from camera, since the repeating pattern looks pretty awful on large terrains
    intensity *= clamp(1.0 - (distance(uCameraPos.xyz, pixelpos.xyz) * distMul), 0.0, 1.0);

    return getTexel(texCoord) * color + vec4(intensity, intensity, intensity, 1);
}