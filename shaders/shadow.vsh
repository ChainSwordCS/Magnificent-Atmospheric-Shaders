#version 120

#include "fastMath.glsl"

#define transMAD(mat, v) (mat3(mat) * (v) + (mat)[3].xyz)

#define diagonal2(mat) vec2((mat)[0].x, (mat)[1].y)
#define diagonal3(mat) vec3(diagonal2(mat), (mat)[2].z)
#define diagonal4(mat) vec4(diagonal3(mat), (mat)[2].w)

varying vec2 uvcoord;

varying vec4 color;

void main() {
	gl_Position = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];
	gl_Position.xy /= 1.0 + fLength(gl_Position.xy);
	gl_Position.z /= 6.0;
	color = gl_Color;

	uvcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
