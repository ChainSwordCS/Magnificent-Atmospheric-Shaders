#version 120

#include "composite_variables.glsl"

#include "lib/light/blackbody.glsl"

#include "sky.glsl"

#define getLandMask(x) (x < (1.0 - near / far / far))

vec3 blockLight = blackbody(2500) * 0.085;

#include "offset.glsl"

#include "lib/light/getShading.glsl"

uniform sampler2D tex;

varying vec2 lmcoord;
varying vec3 normal;
varying vec4 tint;
varying vec3 world;

void main() {

vec4 color = texture2D(tex, texCoord.st);

color.rgb = pow(color.rgb, vec3(2.2));

color.rgb = getShading(color.rgb, world.xyz, lmcoord, normal);

color *= tint;

/* DRAWBUFFERS:67 */
gl_FragData[0] = color;
gl_FragData[1] = vec4(color.a);
}
