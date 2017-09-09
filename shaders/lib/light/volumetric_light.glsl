float getnoise(vec2 pos){
    return fract(sin(dot(pos, vec2(12.9898, 4.1414))) * 43758.5453);
}

float vcnoise(vec3 pos){
    vec3 flr = floor(pos);
    vec3 frc = fract(pos);
    float yadd = 16.0;
    frc = frc*frc*(3.0-2.0*frc);

    /*
    float noise = getnoise(flr.xz+flr.y*yadd);
    return noise
    */

    float noisebdl = getnoise(flr.xz+flr.y*yadd);
    float noisebdr = getnoise(flr.xz+flr.y*yadd+vec2(1.0,0.0));
    float noisebul = getnoise(flr.xz+flr.y*yadd+vec2(0.0,1.0));
    float noisebur = getnoise(flr.xz+flr.y*yadd+vec2(1.0,1.0));
    float noisetdl = getnoise(flr.xz+flr.y*yadd+yadd);
    float noisetdr = getnoise(flr.xz+flr.y*yadd+yadd+vec2(1.0,0.0));
    float noisetul = getnoise(flr.xz+flr.y*yadd+yadd+vec2(0.0,1.0));
    float noisetur = getnoise(flr.xz+flr.y*yadd+yadd+vec2(1.0,1.0));
    float noise= mix(mix(mix(noisebdl,noisebdr,frc.x),mix(noisebul,noisebur,frc.x),frc.z),mix(mix(noisetdl,noisetdr,frc.x),mix(noisetul,noisetur,frc.x),frc.z),frc.y);
    return noise;
}

float get8x8Dither(in vec2 coord)
{
	const int [64] ditherIndexTable = int[64](
	0 , 42, 12, 60, 3 , 51, 15, 63,
	32, 16, 44, 28, 35, 19, 47, 31,
	8 , 56, 4 , 52, 11, 59, 7 , 55,
	40, 24, 36, 20, 43, 27, 39, 23,
	2 , 50, 14, 62, 1 , 49, 13, 61,
	34, 18, 46, 30, 33, 17, 45, 29,
	10, 58, 6 , 54, 9 , 57, 5 , 53,
	42, 26, 38, 22, 41, 25, 37, 21);

	ivec2 tableCoord = ivec2(coord) & 7;

	float dither64 = ditherIndexTable[tableCoord.y * 8 + tableCoord.x];
	float dither01 = dither64 * 0.015625;

	return dither01;
}

vec4 getNoise3D(vec3 coord) {
	coord.xy /= noiseTextureResolution;

	vec3 fl = floor(coord);
	vec3 fr = fract(coord);

	vec4 noisel = texture2D(noisetex, (fl.xy + ( fl.z        * 1.0 / noiseTextureResolution)) + fr.xy);
	vec4 noiseh = texture2D(noisetex, (fl.xy + ((fl.z + 1.0) * 1.0 / noiseTextureResolution)) + fr.xy);

	return mix(noisel, noiseh, fr.z);
}

float groundFog(vec3 worldPos) {
	worldPos.y -= 70.0;
	float density = vcnoise(worldPos / vec3(6.0, 3.0, 6.0));
	density *= exp(-worldPos.y / 8.0);
	density = clamp(density, 0.002, 50.0);
	return density * 1.0;
}

vec3 VL() {
    vec4 endPos = gbufferProjectionInverse * (vec4(texCoord.st, texture2D(depthtex0, texCoord.st).r, 1.0) * 2.0 - 1.0);
    endPos /= endPos.w;
    if(isEyeInWater == 1) endPos.xy *= gbufferProjection[1][1] * tan(atan(1.0 / gbufferProjection[1][1]) * 0.85);
    endPos = shadowProjection * shadowModelView * gbufferModelViewInverse * endPos;
    vec4 startPos = shadowProjection * shadowModelView * gbufferModelViewInverse * vec4(0.0, 0.0, 0.0, 1.0);
    vec4 dir = fNormalize(endPos - startPos);

    vec4 increment = dir * distance(endPos, startPos) / STEPS;
    startPos -= increment * get8x8Dither(gl_FragCoord.st);
    vec4 curPos = startPos;



    vec3 result = vec3(0.0);
    for (int i = 0; i < STEPS; i++) {
        curPos += increment;
        vec3 shadowPos = curPos.xyz / vec3(vec2(1.0 + fLength(curPos.xy)), 6.0) * 0.5 + 0.5;
        float shadowOpaque = float(texture2D(shadowtex0, shadowPos.st).r > shadowPos.p);
        float shadowTransparent = float(texture2D(shadowtex1, shadowPos.st).r > shadowPos.p);
        vec3 shadowColor = texture2D(shadowcolor0, shadowPos.st).rgb;
        vec3 shadow = mix(vec3(shadowOpaque), shadowColor, float(shadowTransparent > shadowOpaque));
        result += shadow * length(increment) * groundFog((shadowModelViewInverse * shadowProjectionInverse * curPos).xyz + cameraPosition);
    }

    return result * 0.1;
}
