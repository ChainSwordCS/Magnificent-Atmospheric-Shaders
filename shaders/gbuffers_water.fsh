#version 120

#include "composite_variables.glsl"

#include "lib/light/blackbody.glsl"

#include "sky.glsl"

#define getLandMask(x) (x < (1.0 - near / far / far))

vec3 blockLight = blackbody(2500) * 0.085;

#include "lib/light/getShading.glsl"

uniform sampler2D tex;

varying vec2 lmcoord;
varying vec3 normal;
varying vec4 tint;

void main() {

vec4 color = texture2D(tex, texCoord.st);

color.rgb = pow(color.rgb, vec3(2.2));

vec4 view = vec4(vec3(gl_FragCoord.st / vec2(viewWidth, viewHeight), gl_FragCoord.z) * 2.0 - 1.0, 1.0);
if(isEyeInWater == 1) view.xy *= gbufferProjection[1][1] * tan(atan(1.0 / gbufferProjection[1][1]) * 0.85);
view /= view.w;
vec4 world = gbufferModelViewInverse * view;
world /= world.w;

color.rgb = getShading(color.rgb, world.xyz, lmcoord);

color *= tint;

/* DRAWBUFFERS:67 */
gl_FragData[0] = color;
gl_FragData[1] = vec4(color.a);
}
