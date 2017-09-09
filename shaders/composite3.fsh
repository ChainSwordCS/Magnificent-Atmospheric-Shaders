#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "composite_variables.glsl"

const bool colortex3MipmapEnabled = true;

#include "sky.glsl"

//#define VolumetricLight

#include "lib/light/vl_filter.glsl"

#define getLandMask(x) (x < (1.0 - near / far / far))

vec3 viewVector = normalize((gbufferProjectionInverse * vec4(texCoord.st * 2.0 - 1.0, 0.5, 1.0)).xyz / (gbufferProjectionInverse * vec4(texCoord.st * 2.0 - 1.0, 0.5, 1.0)).w);

float square (float x) { return x * x; }
vec2  square (vec2  x) { return x * x; }
vec3  square (vec3  x) { return x * x; }
vec4  square (vec4  x) { return x * x; }

float phaseFunc(
	in float cosTheta,
	in float g
) {
	float g2 = square(g);

	float p1 = (3.0 * (1.0 - g2)) / (2.0 * (2.0 + g2));
	float p2 = (1.0 + square(cosTheta)) / pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5);

	return p1 * p2;
}

float rayleighPhase(
	in float cosTheta
) {
	return 0.75 * (1.0 + square(cosTheta));
}

/* DRAWBUFFERS:04 */

void main() {
	vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex1, texCoord.st).r;

	#ifdef VolumetricLight
	color.rgb += filterVL(texCoord) * (phaseFunc(dot(viewVector, lightVector), 0.2) + rayleighPhase(dot(viewVector, sunVector)) * (js_getScatter(vec3(0.0), lightVector, lightVector, 0) + js_getScatter(vec3(0.0), upVector, lightVector, 0))) / 240.0;
	#endif

	gl_FragData[0] = vec4(color, 1.0);
	#ifdef TDLAA
	gl_FragData[1] = vec4(texture2D(colortex4, texCoord).rgb, 1.0);
	#endif
}
