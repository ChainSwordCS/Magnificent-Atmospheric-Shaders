#version 120

varying vec4 color;

varying vec3 normal;

varying vec2 uvcoord;
varying vec2 lmcoord;

varying vec4 metadata;

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {
	/* DRAWBUFFERS:012 */
    gl_FragData[0] = color * texture2D(texture, uvcoord);
    gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
	gl_FragData[2] = vec4(lmcoord, metadata.x / 255.0, 1.0);
}
