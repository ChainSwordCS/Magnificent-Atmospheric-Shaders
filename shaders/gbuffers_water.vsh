#version 120

#include "composite_variables.glsl"

#define transMAD(mat, v) (mat3(mat) * (v) + (mat)[3].xyz)

#define diagonal2(mat) vec2((mat)[0].x, (mat)[1].y)
#define diagonal3(mat) vec3(diagonal2(mat), (mat)[2].z)
#define diagonal4(mat) vec4(diagonal3(mat), (mat)[2].w)

varying vec2 lmcoord;
varying vec4 tint;
varying vec3 normal;
varying vec3 world;

varying float idData;

attribute vec4 mc_Entity;

void main() {

    gl_Position = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz).xyzz;
	 world = transMAD(gbufferModelViewInverse, gl_Position.xyz);
	 gl_Position = gl_Position * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];

    texCoord = gl_MultiTexCoord0.st;
    lmcoord = gl_MultiTexCoord1.st / 240.0;
    lmcoord *= vec2(1.0, 0.7);
    tint = gl_Color;

    normal = fNormalize(gl_NormalMatrix * gl_Normal);

    sunVector = fNormalize(sunPosition);
    moonVector = fNormalize(-sunPosition);

    lightVector = (sunAngle > 0.5) ? moonVector : sunVector;

    vec2 noonNight   = vec2(0.0);
     noonNight.x = (0.25 - clamp(sunAngle, 0.0, 0.5));
     noonNight.y = (0.75 - clamp(sunAngle, 0.5, 1.0));

    // NOON
    timeVector.x = 1.0 - clamp01(pow2(abs(noonNight.x) * 4.0));
    // NIGHT
    timeVector.y = 1.0 - clamp01(pow(abs(noonNight.y) * 4.0, 128.0));
    // SUNRISE/SUNSET
    timeVector.z = 1.0 - (timeVector.x + timeVector.y);
    // MORNING
    timeVector.w = 1.0 - ((1.0 - clamp01(pow2(max0(noonNight.x) * 4.0))) + (1.0 - clamp01(pow(max0(noonNight.y) * 4.0, 128.0))));

    idData = mc_Entity.x / 255.0;
}
