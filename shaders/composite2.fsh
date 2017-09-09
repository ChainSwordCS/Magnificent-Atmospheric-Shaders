#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "composite_variables.glsl"

//#define VolumetricLight

#define STEPS 2	//[2 4 6 8 10 12 14 16 18]

#include "lib/light/volumetric_light.glsl"
#include "lib/postprocess/dlaa_1.glsl"

void main() {
	/* DRAWBUFFERS:314 */

	#ifdef TDLAA
	#include "lib/postprocess/dlaa_2.glsl"
	gl_FragData[0] = aaResult;
	#else
	gl_FragData[0] = texture2D(colortex0, texCoord);
	#endif

	#ifdef VolumetricLight
	gl_FragData[1] = vec4(VL(), 1.0);
	#else
	gl_FragData[1] = vec4(0.0);
	#endif
}
