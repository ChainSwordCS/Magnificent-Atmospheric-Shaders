float get8x8Dither(in vec2 coord)
{
	const int [64] ditherIndexTable = int[64](
	0 , 42, 12, 60, 3 , 51, 15, 63,
	32, 16, 44, 28, 35, 19, 47, 31,
	8 , 56, 4 , 52, 11, 59, 7 , 55,
	40, 24, 36, 20, 43, 27, 39, 23,
	2 , 50, 14, 62, 1 , 49, 13, 61,
	34, 18, 46, 30, 33, 17, 45, 29,
	10, 58, 6 , 54, 9 , 57, 5 , 53,
	42, 26, 38, 22, 41, 25, 37, 21);

	ivec2 tableCoord = ivec2(coord) & 7;

	float dither64 = ditherIndexTable[tableCoord.y * 8 + tableCoord.x];
	float dither01 = dither64 * 0.015625;

	return dither01;
}

#include "linearDepth.glsl"

vec3 filterVL(vec2 coord) {
	const float range = 2.5;
	float refDepth = getLinearDepth(texture2D(depthtex0, coord).r);

	vec3 result = vec3(0.0);
	float totalWeight = 0.0;
	for (float i = -range; i <= range; i++) {
		for (float j = -range; j <= range; j++) {
			vec2 sampleOffset = vec2(i, j) / vec2(viewWidth, viewHeight);

			float sampleDepth = getLinearDepth(texture2D(depthtex0, coord + sampleOffset).r);
			float weight = 150.0 - distance(sampleDepth, refDepth);

			result += texture2DLod(colortex1, coord + sampleOffset, 2.5).rgb * weight;
			totalWeight += weight;
		}
	}
	return result / totalWeight * 10.0;
}
