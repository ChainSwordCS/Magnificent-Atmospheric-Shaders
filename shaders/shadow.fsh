#version 120

#include "fastMath.glsl"

varying vec2 uvcoord;

varying vec4 color;

uniform sampler2D texture;

void main() {
	gl_FragData[0] = texture2D(texture, uvcoord) * color;
}
