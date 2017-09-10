#define SHADOWBLUR_RADIUS 0.00035   //[0.00009 0.00035 0.00065 0.001 0.004 0.007 0.03]

vec3 getShading(in vec3 color, in vec3 world, in vec2 surface, in vec3 normal) {

    mat4 shadowMVP = shadowProjection * shadowModelView;
    vec4 shadowPos  = shadowMVP * vec4(world, 1.0);

	shadowPos.xy /= 1.0 + fLength(shadowPos.xy);
    shadowPos.z /= 6.0;

    shadowPos = shadowPos * 0.5 + 0.5;

    vec3 shadows = vec3(0.0);
    for (int i = 0; i < offset.length(); i++) {
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