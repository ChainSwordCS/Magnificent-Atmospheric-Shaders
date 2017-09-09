#define SHADOWBLUR_RADIUS 0.00035   //[0.00009 0.00035 0.00065 0.001 0.004 0.007 0.03]

    const vec2[36] offset = vec2[36](
        vec2(-0.90167680,  0.34867350),
        vec2(-0.98685560, -0.03261871),
        vec2(-0.67581730,  0.60829530),
        vec2(-0.47958790,  0.23570540),
        vec2(-0.45314310,  0.48728980),
        vec2(-0.30706600, -0.15843290),
        vec2(-0.09606075, -0.01807100),
        vec2(-0.60807480,  0.01524314),
        vec2(-0.02638345,  0.27449020),
        vec2(-0.17485240,  0.49767420),
        vec2( 0.08868586, -0.19452260),
        vec2( 0.18764890,  0.45603400),
        vec2( 0.39509670,  0.07532994),
        vec2(-0.14323580,  0.75790890),
        vec2(-0.52281310, -0.28745570),
        vec2(-0.78102060, -0.44097930),
        vec2(-0.40987180, -0.51410110),
        vec2(-0.12428560, -0.78665660),
        vec2(-0.52554520, -0.80657600),
        vec2(-0.01482044, -0.48689910),
        vec2(-0.45758520,  0.83156060),
        vec2( 0.18829080,  0.71168610),
        vec2( 0.23589650, -0.95054530),
        vec2( 0.26197550, -0.61955050),
        vec2( 0.47952230,  0.32172530),
        vec2( 0.52478220,  0.61679990),
        vec2( 0.85708400,  0.47555550),
        vec2( 0.75702890,  0.08125463),
        vec2( 0.48267020,  0.86368290),
        vec2( 0.33045960, -0.31044460),
        vec2( 0.59658700, -0.35501270),
        vec2( 0.69684450, -0.61393110),
        vec2( 0.88014110, -0.41306840),
        vec2( 0.07468465,  0.99449370),
        vec2( 0.92697510, -0.10826900),
        vec2( 0.45471010, -0.78973980)
    );

vec3 getShading(in vec3 color, in vec3 world, in vec2 surface, in vec3 normal) {

    mat4 shadowMVP = shadowProjection * shadowModelView;
    vec4 shadowPos  = shadowMVP * vec4(world, 1.0);

	shadowPos.xy /= 1.0 + fLength(shadowPos.xy);
    shadowPos.z /= 6.0;

    shadowPos = shadowPos * 0.5 + 0.5;

    vec3 shadows = vec3(0.0);
    for (int i = 0; i < 36; i++) {
    float shadowOpaque = float(texture2D(shadowtex0, offset[i] * 0.00044 + shadowPos.st ).r > shadowPos.p - 0.000085);
    float shadowTransparent = float(texture2D(shadowtex1, offset[i] * 0.00034 + shadowPos.st ).r > shadowPos.p - 0.000085);
    vec3 shadowColor = texture2D(shadowcolor0, offset[i] * 0.00074 + shadowPos.st).rgb;
    vec3 shadow = mix(vec3(shadowOpaque), shadowColor, float(shadowTransparent > shadowOpaque));
    shadows += shadow;
    }
    shadows /= 36.0;
    vec3 lighting = vec3(0.0);

    // direct
    lighting = (0.0045 * js_getScatter(vec3(0.0), lightVector, lightVector, 0) * max(0.0, dot(normal, lightVector))) * shadows + lighting;

    // ambient
    lighting = (8.3 * js_getScatter(vec3(0.0), upVector, lightVector, 0) * (0.35 * timeVector.x + 25.5 * timeVector.y + 0.6 * timeVector.z) ) * (pow(surface.g, 7.0)) + lighting;

    // block
    lighting = blockLight * (pow(surface.r, 7.0)) + lighting;

    return color.rgb * lighting;
    }