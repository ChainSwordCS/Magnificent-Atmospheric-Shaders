#version 120

varying vec4 color;

varying vec3 normal;

varying vec2 uvcoord;
varying vec2 lmcoord;

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {
	/* DRAWBUFFERS:012 */
	gl_FragData[0] = texture2D(texture, uvcoord) * color;
	gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
	gl_FragData[2] = vec4(lmcoord, 1.0, 1.0);
}
