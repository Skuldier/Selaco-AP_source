// Original credit for this shader goes to Simon Harris (SimonHarris.co)
// Adapted for GZDoom by @Cockatrice
// TODO: Increase grain in dark areas and decrease in light areas

float randomGelf(vec2 p) {
    vec2 K1 = vec2(
        23.14069263277926, // e^pi (Gelfond's constant)
        2.665144142690225 // 2^sqrt(2) (Gelfond–Schneider constant)
    );
    return fract( cos( dot(p,K1) ) * 12345.6789 );
}


void main() {
    ivec2 texSize = textureSize(InputTexture, 0);
    vec4 color = texture( InputTexture, TexCoord );
    vec2 uvRandom = vec2( floor(float(texSize.x) * TexCoord.x * scale), floor(float(texSize.y) * TexCoord.y * scale));
    uvRandom.y *= randomGelf(uvRandom * ttime);
    color.rgb += ((0.5 - randomGelf(uvRandom)) * intensity * 0.5) * min(floor(texSize.x / 320.0), 1.0);     // This will prevent the effect from rendering in smaller than 320x??? resolutions (screenshots)
    FragColor = vec4( color );
}