#version 120

//#define UnderwaterBlur    //Blurs the screen underwater. Currently broken.
//#define ScreenBlur    //Blurs the screen. This will eventually be turned into DOF.
#define ScreenSpaceFog    //This is for people who cannot run the intense Vl this shader has to offer, turn this off when enabling VL to avoid any issues that may occur. This effect is unrealistic, so if you prefer realism over FPS, go enable VL and disable this.
#define ScreenSpaceFogAmount 0.078 //[0.02 0.04 0.06 0.08 0.1 0.3 0.5 0.7 0.9] This controls intensity, if you go to about 0.3 and up, the fog is insanely visible.

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

const float pi  = 3.14159265358979;
const float tau = 6.28318530718;

float getLuma(in vec3 colour) { return dot(colour, vec3(0.2125, 0.7154, 0.0721)); }
vec3 colourSaturation(in vec3 colour, in float saturation) { return colour * saturation + getLuma(colour) * (1.0 - saturation); }

#define DIRECT_MOONLIGHT_SATURATION 0.1

  vec3 moonLight = colourSaturation(vec3(0.0, 0.0, 1.0), DIRECT_MOONLIGHT_SATURATION) * 0.5;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex4;

uniform float viewWidth, viewHeight;
uniform float far, near;

uniform mat4 gbufferModelView;

uniform int isEyeInWater;

varying vec2 texCoord;
varying vec2 TexCoord;

varying vec3 sunVector;
varying vec3 moonVector;
varying vec3 lightVector;

varying vec4 timeVector;

#define upVector gbufferModelView[1].xyz

#include "sky.glsl"

vec3 noonLight = vec3(.1, .6, .8) * 0.6;
vec3 horizonLight = vec3(.1, 1.95, .7) * 0.1;
vec3 nightColor = vec3(.1, .6, .9) * 0.2;

vec3 fogLight = (noonLight * timeVector.x + noonLight * nightColor * timeVector.y + horizonLight * timeVector.z);

vec3 noonLight2 = vec3(.4, 1.1, 1.5);
vec3 horizonLight2 = vec3(3., 2., .7);
vec3 nightColor2 = vec3(.4, .7, 1.5) * 0.004;

vec3 fogLight2 = (noonLight2 * timeVector.x + noonLight2 * nightColor2 * timeVector.y + horizonLight2 * timeVector.z);

#define getLandMask(x) (x < (1.0 - near / far / far))

void toneMap(inout vec3 color){
    color *= 3.0;

    color = color / (1.0 + color);
}

vec3 srgbToLinear(vec3 srgb){
    return mix(
        srgb / 12.92,
        pow(.947867 * srgb + .0521327, vec3(2.4) ),
        step( .04045, srgb )
    );
}

vec3 linearToSRGB(vec3 linear){
    return mix(
        linear * 12.92,
        pow(linear, vec3(1./2.4) ) * 1.055 - .055,
        step( .0031308, linear )
    );
}

vec3 jodieRoboTonemap(vec3 c){
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
    vec3 tc=c/sqrt(c*c+1.);
    return mix(c/sqrt(l*l+1.),tc,tc);
}
vec3 jodieReinhardTonemap(vec3 c){
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
    vec3 tc=c/(c+1.);
    return mix(c/(l+1.),tc,tc);
}

#include "offset.glsl"

void main() {
    vec3 color = texture2D(colortex0, texCoord.st).rgb;
    float depth = texture2D(depthtex1, texCoord.st).r;

    float fog = texture2D(depthtex0,TexCoord).r;
    
    float fogStart = 0.988;
    float fogEnd = 1.0;
    float fogFactor = 1.0;
    
    fog = smoothstep(fogStart, fogEnd, fog) * fogFactor;
    
    vec4 fogColor = vec4(fogLight,1.0);

    float fog2 = texture2D(depthtex0,TexCoord).r;
    
    float fogStart2 = 0.99;
    float fogEnd2 = 1.0;
    float fogFactor2 = ScreenSpaceFogAmount;
    
    fog2 = smoothstep(fogStart2, fogEnd2, fog2) * fogFactor2;
    
    vec4 fogColor2 = vec4(fogLight2,1.0);

    color.rgb = pow(color.rgb, vec3(2.2));

    #ifdef UnderwaterBlur
    #include "lib/postprocess/underwaterblur.glsl"
    #endif

    #ifdef ScreenBlur
    #include "lib/postprocess/screenBlur.glsl"
    #endif

    toneMap(color);
    //color = pow(color, vec3(2.2));


    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

    gl_FragColor = vec4(color, 1.0);
    #ifdef ScreenSpaceFog
    if(getLandMask(depth)) gl_FragColor =	texture2D(colortex0,TexCoord) * (1.0-fog2) + fogColor2*fog2;
    #endif
    if (isEyeInWater > 0) {
     gl_FragColor =	texture2D(colortex0,TexCoord) * (1.0-fog) + fogColor*fog;
    }
}
