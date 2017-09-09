float fLength(vec4 x){
  return sqrt(dot(x,x));
}

float fLength(vec3 x){
  return sqrt(dot(x,x));
}

float fLength(vec2 x){
  return sqrt(dot(x,x));
}

vec4 fNormalize(vec4 x){
  return x / fLength(x);
}

vec3 fNormalize(vec3 x){
  return x / fLength(x);
}

vec2 fNormalize(vec2 x){
  return x / fLength(x);
}