#version 120

#include "composite_variables.glsl"

void main() {
    gl_Position = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];

    texCoord = gl_MultiTexCoord0.st;
}