#define upVector gbufferModelView[1].xyz

#define PIXEL_SIZE vec2(1.0/width, 1.0/height)

//#define TDLAA //Does not seem to be working for some reason.

const bool colortex4Clear = false;

/* Uniforms */

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4; //TDLAA, aka Temporal Directionally Localized Anti Aliasing
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

uniform float sunAngle;
uniform float viewWidth, viewHeight;
uniform float far, near;
uniform float frameTime;
uniform float rainStrength;

uniform int isEyeInWater;
uniform int worldTime;

uniform vec3 sunPosition;
uniform vec3  cameraPosition;
uniform vec3 previousCameraPosition;

uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse, gbufferProjection;
uniform mat4 shadowModelView, shadowProjection;
uniform mat4 shadowModelViewInverse, shadowProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

/* Varyings */
varying vec4 timeVector;
varying vec4 texcoord;

varying vec3 sunVector;
varying vec3 moonVector;
varying vec3 lightVector;

varying vec2 texCoord;

/* Floats */

float width = viewWidth; //texture width
float height = viewHeight; //texture height

float timefract = worldTime;

/* Const */

const float sunPathRotation = -40.0;

const int shadowMapResolution = 3072; //[2 4 8 16 32 64 128 256 512 1024 2048 4096 8192]
const float shadowDistance = 60.0;

const int noiseTextureResolution = 128;

const float pi  = 3.14159265358979;
const float tau = 6.28318530718;

const bool colortex5Clear = false;
const bool colortex0MipmapEnabled = true;

/* Random variables */
float getLuma(in vec3 colour) { return dot(colour, vec3(0.2125, 0.7154, 0.0721)); }
vec3 colourSaturation(in vec3 colour, in float saturation) { return colour * saturation + getLuma(colour) * (1.0 - saturation); }

#define DIRECT_MOONLIGHT_SATURATION 0.05

  vec3 moonLight = colourSaturation(vec3(0.0, 0.0, 1.0), DIRECT_MOONLIGHT_SATURATION) * 0.5;

/* Formats */

/*
  const int colortex0Format = RGBA16;
  const int colortex1Format = RGB16;
  const int colortex2Format = RGB16;
  const int colortex5Format = R16F;
  const int colortex6Format = RGB16;
*/

/* Macros */

#define transMAD(mat, v) (mat3(mat) * (v) + (mat)[3].xyz)

#define diagonal2(mat) vec2((mat)[0].x, (mat)[1].y)
#define diagonal3(mat) vec3(diagonal2(mat), (mat)[2].z)
#define diagonal4(mat) vec4(diagonal3(mat), (mat)[2].w)

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

/* Includes */

#include "fastMath.glsl"
