// I use this oneliner that I found on the internet somewhere 
// - Some guy on the Internet
float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 staticDrops(float rainAmount, vec2 texCoord, vec2 screenSize) {
	const float oneEighty = 180 * 0.01745329;
	const float flowSpeed = 45.0 * 0.01745329;
	const float dropTime = 2.0;
	const float dropDelay = 13.5;
    const float timeOffsetMultiplier = dropDelay * 1.5;//6.5;
    const float displacement = 0.03;
    
    vec2 dropsSize = textureSize(rippleTex, 0);
    float rRatio = (dropsSize.y / dropsSize.x) / (screenSize.y / screenSize.x);
    vec2 tCoord = vec2((texCoord.x * rRatio) + ((1.0 - rRatio) * 0.5), texCoord.y) * 2.1;
    vec4 tcol = texture(rippleTex, tCoord);
	vec3 normal = normalize(vec3(tcol * 2.0 - 1.0));

	float T = timer;
    vec4 controlCol = texture(controlTex, tCoord);

	float tCoordOffset = rand(vec2(floor(tCoord.y), floor(tCoord.x))) * dropDelay;
	T += controlCol.b * timeOffsetMultiplier; // Offset time with blue channel
	T += tCoordOffset;                  // Shift offset a bit for every tile, so tiles don't resemble each other
                                        // Because of this behaviour the input texture cannot have elements that wrap over the edges!

	T += controlCol.b * timeOffsetMultiplier; // Offset time with blue channel

    float dropAmount = clamp((rainAmount - controlCol.g) * 10.0, 0.0, 1.0);
	float dt = floor(T / dropDelay) * dropDelay;
	float dtt = ((T - dt) / dropTime) + (1.0 - dropAmount);
	float dropPhase = clamp( pow(dtt, 3), 0.0f, 1.0f);
	float droopPhase = clamp( dtt, 0.0f, 1.0f);
	float intensity = clamp(controlCol.a * dropAmount * (1.0 - dropPhase) * cos((dropPhase * oneEighty) + (droopPhase * controlCol.r * flowSpeed)) , 0.0, 1.0);
	
	vec4 disTex = texture(InputTexture, texCoord - ((normal.xy * displacement) * controlCol.a * intensity));
	//vec4 origTex = texture(InputTexture, texCoord);
	//return mix(origTex, disTex, intensity);
	return disTex;
}


void main() {
    ivec2 texSize = textureSize(InputTexture, 0);
    vec4 color = texture( InputTexture, TexCoord );
    
    color = staticDrops(amount, TexCoord + offset, texSize) * 1.0;

    FragColor = vec4( color );
}

// I use this oneliner that I found on the internet somewhere 
// - Some guy on the Internet
/*float rand1(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 rand2(vec2 c){
    mat2 m = mat2(12.9898,.16180,78.233,.31415);
	return fract(sin(m * c) * vec2(43758.5453, 14142.1));
}

vec2 noise(vec2 p){
	vec2 co = floor(p);
	vec2 mu = fract(p);
	mu = 3.*mu*mu-2.*mu*mu*mu;
	vec2 a = rand2((co+vec2(0.,0.)));
	vec2 b = rand2((co+vec2(1.,0.)));
	vec2 c = rand2((co+vec2(0.,1.)));
	vec2 d = rand2((co+vec2(1.,1.)));
	return mix(mix(a, b, mu.x), mix(c, d, mu.x), mu.y);
}


void main()
{
	const vec2 grid = vec2(19.2, 10.8);
	const float warp = 3.0;
	const float dropSize = 1.0;
    const float refraction = 0.17;

	vec2 vRes = vec2(1.0, 1.0);
	vec4 f;
	vec2 c = TexCoord + offset;
	vec2 u = c / vRes.xy,
         v = (c*.1)/ vRes.xy,
         n = noise(v*150); // Displacement
    
    float amountDrops = amount * 0.3;
    
    f = texture(InputTexture, u);

    // Loop through the different inverse sizes of drops
    for (int r = 4; r > 0 ; r--) {
        vec2 x = grid.xy * float(r),  // Number of potential drops (in a grid)
             p = 6.28 * u * x + (n - .5) * warp,
             s = sin(p);
        
        // Current drop properties. Coordinates are rounded to ensure a
        // consistent value among the fragment of a given drop.
        vec2 v = round(u * x - 0.25) / x;
        vec4 d = vec4(noise(v*400), noise(v));
        
        
        // Drop shape and fading
        float t = (s.x+s.y) * max(0., (0.4 * dropSize) - fract(timer * (d.b + .05) + d.g) * (0.5 * dropSize));
        
        // Ensure size is larger than threshold (0.5)
        float rval = clamp(ceil(t - 0.5), 0.0, 1.0);
        
        // Gently fade a little between amounts, so when reducing amount it does not snap drops off screen
        float val = clamp( (amountDrops - d.r) * 20.0, 0.0, 1.0) * rval;
        {
            // Drop normal
            vec3 v = normalize(-vec3(cos(p), mix(.2, 2., t-.5)));

            // Poor man's refraction (no visual need to do more)
            f = mix(f, texture(InputTexture, u - v.xy * refraction), val);
        }
    }
    
    FragColor = f;
}*/


// Basically copied from the raindrops code
/*vec4 staticDrops(float rainAmount, vec2 texCoord, vec2 screenSize) {
    const float threeSixty = 360 * 0.01745329;
	const float oneEighty = 180 * 0.01745329;
	const float flowSpeed = 45.0 * 0.01745329;
	const float dropTime = 5.0;
	const float dropDelay = 9.5;
    const float timeOffsetMultiplier = 6.5;

	float T = timer;

    vec2 texSize2 = textureSize(rippleTex, 0);

    // Adjust for aspect ratio difference
    // Assume V > H which is true for most cases
    float rRatio = (texSize2.y / texSize2.x) / (screenSize.y / screenSize.x);
    vec2 tCoord = vec2((texCoord.x * rRatio) + ((1.0 - rRatio) * 0.5), -texCoord.y);
    vec4 tcol = texture(rippleTex, tCoord);

	T += tcol.b * timeOffsetMultiplier; // Offset time with blue channel


    float dropAmount = clamp((rainAmount - tcol.g) * 10.0, 0.0, 1.0);
	float dt = floor(T / dropDelay) * dropDelay;
	float dtt = ((T - dt) / dropTime) + (1.0 - dropAmount);
	float dropPhase = clamp( dtt * dtt * dtt * dtt, 0.0f, 1.0f);
	float droopPhase = clamp( dtt, 0.0f, 1.0f);
	float intensity = clamp(tcol.a * dropAmount * (1.0 - dropPhase) * ( cos((dropPhase * oneEighty) + (droopPhase * tcol.r * flowSpeed)) ), 0.0, 1.0);
	

    return vec4(intensity, intensity, intensity, 1.0);
}


void main() {
    ivec2 texSize = textureSize(InputTexture, 0);
    vec4 color = texture( InputTexture, TexCoord );
    
    color += staticDrops(amount, TexCoord + offset, texSize) * 0.25;

    FragColor = vec4( color );
}*/