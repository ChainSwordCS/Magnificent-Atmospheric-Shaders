#version 120

varying vec4 color;

varying vec2 uvcoord;

varying vec3 normal;

uniform sampler2D texture;

void main() {
	/* DRAWBUFFERS:01 */
gl_FragData[0] = texture2D(texture, uvcoord) * color;
gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
}
