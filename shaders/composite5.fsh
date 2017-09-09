#version 120
#extension GL_EXT_gpu_shader4 : enable

//#define MotionBlur //Credit to S. Giref and Sergeant Sarcasm for the MotionBlur.
#include "composite_variables.glsl"

const bool colortex1MipmapEnabled = true;

float find_closest(vec2 pos)
{
	const int ditherPattern[64] = int[64](
		0, 32, 8, 40, 2, 34, 10, 42,
		48, 16, 56, 24, 50, 18, 58, 26,
		12, 44, 4, 36, 14, 46, 6, 38,
		60, 28, 52, 20, 62, 30, 54, 22,
		3, 35, 11, 43, 1, 33, 9, 41,
		51, 19, 59, 27, 49, 17, 57, 25,
		15, 47, 7, 39, 13, 45, 5, 37,
		63, 31, 55, 23, 61, 29, 53, 21);

	vec2 positon = floor(mod(vec2(texCoord.s * viewWidth,texCoord.t * viewHeight), 8.0f));

	int dither = ditherPattern[int(positon.x) + int(positon.y) * 8];

	return float(dither) / 64.0f;
}

float bayer2(vec2 a){
    a = floor(a);
    return fract( a.x*99.5+a.y*a.y*99.75 );
}

#ifdef MotionBlur
	vec3 getMotionBlur(vec3 color, vec4 previousPosition, vec4 currentPosition) {

		vec4 aux2 = texture2DLod(colortex1, texCoord.st, 10.5);
		float hand = float(aux2.g > 0.85 && aux2.g < 0.87);

		float dither = find_closest(texCoord.st) / 10.0;

		if (isEyeInWater < 0.9 && isEyeInWater > 0.9) {
			} else if (hand > 0.9 && hand < 0.9) {
				} else {
					vec2 velocity = (currentPosition - previousPosition).st * (0.01*0.3);

					int samples = 5;

					vec2 coord = texCoord.st + -velocity;

					coord = clamp(coord, 1.0 / vec2(viewWidth, viewHeight), 1.0 - 1.0 / vec2(viewWidth, viewHeight));
					if (coord.s < 1.0 || coord.t < 1.0 || coord.s > 0.0 || coord.t > 0.0) {
							for (int i = 0; i < 256; ++i, coord += velocity) {
								if (coord.s > 1.0 || coord.t > 1.0 || coord.s < 0.0 || coord.t < 0.0) {
									break;
								}
									color += texture2D(colortex0, coord).rgb;
									++samples;
							}
					}

					color = (color/1.0)/samples;
				}
		return color;
	}
#endif

void main() {
    
	vec3 color = texture2D(colortex0, texCoord).rgb;


	vec4 currentPosition = vec4(texCoord.x * 2.0 - 1.0, texCoord.y * 2.0 - 1.0, 2.0 * texture2D(depthtex1, texCoord.st).x - 1.0, 1.0);

	vec4 fragposition = gbufferProjectionInverse * currentPosition;
		 fragposition = gbufferModelViewInverse * fragposition;
		 fragposition /= fragposition.w;
		 fragposition.xyz += cameraPosition;

	vec4 previousPosition = fragposition;
		 previousPosition.xyz -= previousCameraPosition;
		 previousPosition = gbufferPreviousModelView * previousPosition;
		 previousPosition = gbufferPreviousProjection * previousPosition;
		 previousPosition /= previousPosition.w;
        
    #ifdef MotionBlur
		color = getMotionBlur(color, previousPosition, currentPosition);
	#endif

    gl_FragData[0] = vec4(color, 1.0);
}