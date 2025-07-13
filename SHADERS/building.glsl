const float zStart = 3000.0;
const float zEnd = 3328.0 - zStart;

float loopz(float value, float start, float end) {
    float width       = end - start;
    float offsetValue = value - start;

    return ( offsetValue - ( floor( offsetValue / width ) * width ) ) + start;
}

void SetupMaterial(inout Material mat) {
    float zPos = ModelMatrix[3].y;

    mat.Base = getTexel(vTexCoord.xy) * clamp((zPos - zStart) / zEnd, 0.0, 1.0);
    mat.Bright = texture(brighttexture, vTexCoord.xy);
    mat.SpecularLevel = 0;
    mat.Metallic = 0;
    mat.Roughness = 0;
    mat.AO = 0;

#if defined(selfbright)
    mat.Bright += selfbright;
#endif
}