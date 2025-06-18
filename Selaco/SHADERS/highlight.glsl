uniform float timer;

const float bandUnits = 7.0;
const float scanUnits = 50.0;
const float scanSegUnits = (scanUnits * 2.0) / 3.0;
const float moveSpeed = 63.0;

float loopz(float value, float start, float end) {
    float width       = end - start;
    float offsetValue = value - start;

    return ( offsetValue - ( floor( offsetValue / width ) * width ) ) + start;
}

void SetupMaterial(inout Material mat) {
    mat.Base = getTexel(vTexCoord.xy);
    mat.Bright = texture(brighttexture, vTexCoord.xy);

    float ourPos = ModelMatrix[3].y;

    float shimPhase = loopz((timer * moveSpeed) + ourPos, -scanUnits, scanUnits);
    float shimmer = 1.0 - (clamp(abs(ourPos - pixelpos.y - shimPhase), 0.0, bandUnits) / bandUnits);
    mat.Glow = vec4(shimmer, shimmer, 0.0, 1.0);      // Gold
    //mat.Glow = vec4(0.49020,  0.57647,  1.0, shimmer);  // OMNIBLUish

    mat.SpecularLevel = 0;
    mat.Metallic = 0;
    mat.Roughness = 0;
    mat.AO = 0;

#if defined(selfbright)
    mat.Bright += selfbright;
#endif

// TODO: Implement PBR texture reading

}