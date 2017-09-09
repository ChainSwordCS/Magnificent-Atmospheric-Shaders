#version 120

#include "composite_variables.glsl"

/* DRAWBUFFERS:01 */

void main() {
	vec4 render = texture2D(colortex0, gl_TexCoord[0].st);

	vec4 bloom = vec4(0.0);
	float weights = 0.0;

	float id = texture2D(colortex2, gl_TexCoord[0].st).b;

	float range = 30.0;
	bool emissive = false;

    for (int i = -20; i <= 20; i += 1) {
        for (int j = -10; j <= 10; j += 1) {
            vec2  offset = vec2(i, j);
            float weight = max(1.0 - fLength(offset / vec2(2048, 5)), 0.0);

            float id = texture2D(colortex2, gl_TexCoord[0].st + (offset / vec2(viewWidth, viewHeight))).b;
            //if (floor(id + 0.0001) == 50.0) emissive = true;

            vec4 bloomSample = texture2D(colortex0, gl_TexCoord[0].st + (offset / vec2(viewWidth, viewHeight)));
            // Since we're not doing HDR rendering, we need to make sure bloom only gets added for high enough values.
            bloomSample *= step(vec4(0.8), bloomSample);

            //if (emissive) bloomSample *= 100.0;

            bloom += bloomSample * weight;

             // We need to sum up the weights in order to get a correct result.
            weights += weight;
        }
    }
	bloom /= weights;

	// Add bloom to result
	render += bloom * 0.3;

	gl_FragData[0] = render;
}
