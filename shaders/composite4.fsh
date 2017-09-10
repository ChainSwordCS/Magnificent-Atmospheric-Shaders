#version 120

//#define DepthOfField  //Blurs unfocused areas, currently takes a good chunk of FPS away
    #define Aperture 0.06   //[0.01 0.02 0.03 0.04 0.5 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5] Higher values increase the size of the blur
#include "composite_variables.glsl"

#include "lib/light/linearDepth.glsl"

#include "offset.glsl"

float linearizeDepth(float depth) {
    return -1.0 / ((depth * 2.0 - 1.0) * gbufferProjectionInverse[2].w + gbufferProjectionInverse[3].w);
}

vec3 DOF() {
    float focus = linearizeDepth(centerDepthSmooth);
    float depth = linearizeDepth(texture2D(depthtex0, texCoord).r);
    float coc = Aperture * (abs(depth - focus) / abs(depth)) * ((Aperture * gbufferProjection[1].y) / abs(focus - (Aperture * gbufferProjection[1].y)));

    vec3 result = vec3(0.0);
    for (int i = 0; i < hex_offsets.length(); i++) {
        result += texture2DLod(colortex0, hex_offsets[i] * coc + texCoord, log2(coc * 90 + 1)).rgb;
    }
    result /= 119.0;


    return result;
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    #ifdef DepthOfField
    color = DOF().rgb;
    #endif

    gl_FragData[0] = vec4(color, 1.0);
}