vec4 sampleOffseted(const in sampler2D tex, const in vec2 texCoord, const vec2 pixelOffset )
{
   return texture2D(tex, texCoord + pixelOffset * PIXEL_SIZE);
}

float avg(const in vec3 value)
{
    const float oneThird = 1.0 / 3.0;
   return dot(value.xyz, vec3(oneThird, oneThird, oneThird) );
}


vec4 firsPassEdgeDetect( vec2 texCoord )
{
   vec4 sCenter    = sampleOffseted(colortex0, texCoord, vec2( 0.0,  0.0) );
   vec4 sUpLeft    = sampleOffseted(colortex0, texCoord, vec2(-0.7, -0.7) );
   vec4 sUpRight   = sampleOffseted(colortex0, texCoord, vec2( 0.7, -0.7) );
   vec4 sDownLeft  = sampleOffseted(colortex0, texCoord, vec2(-0.7,  0.7) );
   vec4 sDownRight = sampleOffseted(colortex0, texCoord, vec2( 0.7,  0.7) );

   vec4 diff          = abs(((sUpLeft + sUpRight + sDownLeft + sDownRight) * 4.0) - (sCenter * 16.0));
   float edgeMask       = avg(diff.xyz);

   return vec4(sCenter.rgb, edgeMask);
}

/*
mat4x3 gatherNearPixels(in sampler2D sampleBuffer, in vec2 coord, c(in mat4x2 offsetDirection), in vec2 blurSize) {

    mat4x3 nearPixel = mat4x3(0.0);
   
    nearPixel[0] = textureLoadLOD(sampleBuffer, offsetDirection[0] * blurSize + coord, DLAA_LOD).rgb;
    nearPixel[1] = textureLoadLOD(sampleBuffer, offsetDirection[1] * blurSize + coord, DLAA_LOD).rgb;
    nearPixel[2] = textureLoadLOD(sampleBuffer, offsetDirection[2] * blurSize + coord, DLAA_LOD).rgb;
    nearPixel[3] = textureLoadLOD(sampleBuffer, offsetDirection[3] * blurSize + coord, DLAA_LOD).rgb;

    return nearPixel;
}

mat2x3 matAbs(in mat2x3 value) {
    return mat2x3(abs(value[1]), abs(value[0]));
}

vec3 averageNearPixels(in mat4x3 nearPixel) {
    return (nearPixel[0] + nearPixel[1] + nearPixel[2] + nearPixel[3]) * 0.25;
}

vec2 avg(in mat2x3 value) {
   return vec2(dot(value[0].xyz, vec3(0.33333)), dot(value[1].xyz, vec3(0.33333)));
}

void computeAntiAliasing(io vec3 output0, in mat3x2 currentCoord) {

    output0 = gammaLinear(output0);

    c(mat4x2) offsetDirection = mat4x2(-1.0, 0.0, 1.0, 0.0, 0.0, -1.0, 0.0, 1.0);

    mat4x3 nearPixels = gatherNearPixels(colortex0, currentCoord[1], offsetDirection, pixelSize * DLAA_RADIUS);

    mat2x3 centerMatrix = mat2x3(output0, output0);

    mat2x3 nearPixelMatrix = mat2x3(nearPixels[0] + nearPixels[1], nearPixels[2] + nearPixels[3]);

    vec3 averageNearPixel = averageNearPixels(nearPixels);

    vec2 edge = clamp01(3.0 * avg(matAbs(nearPixelMatrix - (2.0 * centerMatrix)) * 0.5) - 0.1);

    vec2 averageLength = avg((nearPixelMatrix + centerMatrix) * 0.33333);

    vec2 blurWeight = clamp01(edge / averageLength);

    vec3 resolve = mix(output0, averageNearPixel, blurWeight.x * blurWeight.y);

    output0 = gammaNonLinear(resolve);

}
*/