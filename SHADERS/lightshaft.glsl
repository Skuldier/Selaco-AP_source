// A basic shader made to fade the lightshaft effect as you get closer to it @Cockatrice
// Assumes additive mode
uniform float timer;

const float closeDistance   = 64.0;         // Closer than this will be invisible (Standard Doom pixel units)
const float farDistance     = 320.420;      // Farther than this will be fully visible
const float fadeDistance    = farDistance - closeDistance;

vec4 Process(vec4 color)
{
    vec2 texCoord = gl_TexCoord[0].st;
    vec4 fcol = getTexel(texCoord) * color;

#if defined(debug)
    fcol.rgb = vec3(1.0, 0, 0);     // Make the whole thing red only for debugging purposes
#endif

    // Reduce alpha by proximity to camera
    // These are additive, so instead of setting A we just reduce the brightness of the entire thing
    fcol.rgb *= clamp(( distance(uCameraPos.xyz, pixelpos.xyz) - closeDistance) / fadeDistance, 0.0, 1.0);

    return fcol;
}