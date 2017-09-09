#version 120

#include "composite_variables.glsl"

#include "lib/light/blackbody.glsl"

#include "sky.glsl"

#define getLandMask(x) (x < (1.0 - near / far / far))

vec3 blockLight = blackbody(2500) * 0.085;

#include "lib/light/getShading.glsl"
//#include "lib/light/getShadingEXPERIMENTAL.glsl"

void main() {
    vec4 color = texture2D(colortex0, texCoord.st);
    float depth = texture2D(depthtex1, texCoord.st).r;

    vec4 surface = texture2D(colortex2, texCoord.st);

    surface *= vec4(1.0, 0.7, 0.3, 1.0);

    color.rgb = pow(color.rgb, vec3(2.2));

    vec4 view = vec4(vec3(texCoord.st, depth) * 2.0 - 1.0, 1.0);
    view = gbufferProjectionInverse * view;
    if(isEyeInWater == 1) view.xy *= gbufferProjection[1][1] * tan(atan(1.0 / gbufferProjection[1][1]) * 0.85);
    view /= view.w;
    vec4 world = gbufferModelViewInverse * view;
    world /= world.w;

    if(!getLandMask(depth)) color.rgb = js_getScatter(vec3(0.0), fNormalize(view.xyz), lightVector, 0);


    //This line is useless, I was screwing around and testing stuff.
    //if(!getLandMask(depth)) color.rgb *= js_getScatter(vec3(0.0), fNormalize(view.xyz), lightVector, 0);

    if(getLandMask(depth)) color.rgb = getShading(color.rgb, world.xyz, surface.rg, fNormalize(texture2D(colortex1, texCoord).xyz * 2.0 - 1.0));
    //if(getLandMask(depth)) color.rgb = getShading2(color.rgb, world.xyz, surface.rg);

    color = mix(color, texture2D(colortex6, texCoord), texture2D(colortex7, texCoord).r);

    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

	 /* DRAWBUFFERS:01 */

    gl_FragData[0] = color;
    gl_FragData[1] = texture2D(colortex5, texCoord.st);
}
