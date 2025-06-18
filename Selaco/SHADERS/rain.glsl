uniform float timer;

vec4 Process(vec4 color)
{
    vec2 texCoord = gl_TexCoord[0].st;
    ivec2 texSize = textureSize(tex, 0);
    float xzoffset = (((floor(pixelpos.x / 8.0) * 8.0) * 26.25) + ((floor(pixelpos.z / 8.0) * 8.0) * 42.0));
    float speed = 1.0 + (sin(xzoffset / 1024.0) * 0.25);
    texCoord.y = (((pixelpos.y * -0.5) - (timer * speed * 1024.0)) / texSize.y);

    // Add "random" offset based on pixelposx
    texCoord.y += xzoffset / texSize.y;

    return getTexel(texCoord) * color;
}