#version 120

varying vec2 texCoord;
varying vec3 normal;
varying vec4 color;

void main() {
	/* DRAWBUFFERS:0 */
gl_FragData[0] = color;
}
