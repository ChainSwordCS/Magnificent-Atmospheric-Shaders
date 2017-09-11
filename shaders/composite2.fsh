#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "composite_variables.glsl"

//#define VolumetricLight

#define STEPS 2	//[2 4 6 8 10 12 14 16 18]

#include "lib/light/volumetric_light.glsl"



void main() {
	/* DRAWBUFFERS:014 */

	vec4 color = texture2D(colortex0, texCoord.st);

    color = mix(color, texture2D(colortex6, texCoord), texture2D(colortex7, texCoord).r);

    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

	gl_FragData[0] = vec4(color);
	#ifdef VolumetricLight
	gl_FragData[1] = vec4(VL(), 1.0);
	#else
	gl_FragData[1] = vec4(0.0);
	#endif
}
