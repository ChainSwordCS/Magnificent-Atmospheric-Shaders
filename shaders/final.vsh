#version 120

#define sum2(a) dot(a, vec2(1.0))
#define sum3(a) dot(a, vec3(1.0))
#define sum4(a) dot(a, vec4(1.0))

float pow2(in float n)  { return n * n; }
float pow3(in float n)  { return pow2(n) * n; }
float pow4(in float n)  { return pow2(pow2(n)); }
float pow5(in float n)  { return pow2(pow2(n)) * n; }
float pow6(in float n)  { return pow2(pow2(n) * n); }
float pow7(in float n)  { return pow2(pow2(n) * n) * n; }
float pow8(in float n)  { return pow2(pow2(pow2(n))); }
float pow9(in float n)  { return pow2(pow2(pow2(n))) * n; }
float pow10(in float n) { return pow2(pow2(pow2(n)) * n); }
float pow11(in float n) { return pow2(pow2(pow2(n)) * n) * n; }
float pow12(in float n) { return pow2(pow2(pow2(n) * n)); }
float pow13(in float n) { return pow2(pow2(pow2(n) * n)) * n; }
float pow14(in float n) { return pow2(pow2(pow2(n) * n) * n); }
float pow15(in float n) { return pow2(pow2(pow2(n) * n) * n) * n; }
float pow16(in float n) { return pow2(pow2(pow2(pow2(n)))); }

#define max0(n) max(0.0, n)
#define min1(n) min(1.0, n)
#define clamp01(n) clamp(n, 0.0, 1.0)

#include "fastMath.glsl"

varying vec2 texCoord;
varying vec2 TexCoord;

varying vec3 sunVector;
varying vec3 moonVector;
varying vec3 lightVector;

varying vec4 timeVector;

uniform float sunAngle;

uniform vec3 sunPosition;

void main() {
    gl_Position = ftransform();

    texCoord = gl_MultiTexCoord0.st;
    TexCoord = gl_MultiTexCoord0.st;

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
}