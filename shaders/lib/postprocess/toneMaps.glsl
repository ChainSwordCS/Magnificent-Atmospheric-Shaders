//None of these belong to me, and none are used, these are here for testing purposes

/*
vec4 ps_main( vec2 texCoord)
{
   vec3 texColor = texture2D(colortex0, texCoord).rgb;
   texColor *= 16;  // Hardcoded Exposure Adjustment

   float ld = 0.002;
   float linReference = 0.18;
   float logReference = 444;
   float logGamma = 0.45;
      
   vec3 LogColor;
   LogColor.rgb = (log10(0.4*texColor.rgb/linReference)/ld*logGamma + logReference)/1023.f;
   LogColor.rgb = clamp(LogColor.rgb, 0, 1.0);
      
   float FilmLutWidth = 256;
   float Padding = .5/FilmLutWidth;
      
   //  apply response lookup and color grading for target display
   vec3 retColor;
   retColor.r = texture2D(FilmLut, vec2( mix(Padding,1-Padding,LogColor.r), .5)).r;
   retColor.g = texture2D(FilmLut, vec2( mix(Padding,1-Padding,LogColor.g), .5)).r;
   retColor.b = texture2D(FilmLut, vec2( mix(Padding,1-Padding,LogColor.b), .5)).r;

   return vec4(retColor,1);
}
*/
void ps_main(inout vec3 color, vec2 texCoord)
{
   color *= 1;  // Hardcoded Exposure Adjustment
   vec3 x = max(vec3(0),color-0.004);
   color = (x*(6.2*x+.5))/(x*(6.2*x+1.7)+0.06);
}

float A = 2.9;
float B = 0.50;
float C = 0.08;
float D = 0.8;
float E = 0.02;
float F = 0.30;
float W = 11.2;

vec3 Uncharted2Tonemap(vec3 x)
{
   return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

void ps_main2(inout vec3 color, vec2 texCoord)
{
   color *= 0.25;  // Hardcoded Exposure Adjustment

   float ExposureBias = 5.0f;
   vec3 curr = Uncharted2Tonemap(ExposureBias*color);

   vec3 whiteScale = 0.25f/Uncharted2Tonemap(vec3(W));
   vec3 texColor = curr*whiteScale;
      

   vec3 retColor = pow(texColor,vec3(1/2.2));
   color = retColor;
}

// Originally by Jim Hejl and Richard Burgess-Dawson.
// Does not require you to convert to sRGB

void tonemapHejlBurgess(
	inout vec3 color
) {
	//color = max(vec3(0.0), color - 0.004);
	color = (color * (6.2 * color + 0.5)) / (color * (6.2 * color + 1.7) + 0.06);
}

//----------------------------------------------------------------------------//
// Some basic variants of Reinhard

// This one desaturates the image a bit
void tonemapReinhard(
	inout vec3 color
) {
	color /= (1.0 + color);
}

// This one doesn't desaturate the image, but pretty much only darkens the image.
void tonemapReinhardLum(
	inout vec3 color
) {
	color /= (1.0 + (sum3(color) / 3.0));
}

//----------------------------------------------------------------------------//
// Tonemapping operator used in Uncharted 2.
// Source: http://filmicgames.com/archives/75
void tonemapUncharted2(
	inout vec3 color
) {
	const float A = 0.15; // Default: 0.15
	const float B = 0.50; // Default: 0.50
	const float C = 0.10; // Default: 0.10
	const float D = 0.20; // Default: 0.20
	const float E = 0.01; // Default: 0.02
	const float F = 0.30; // Default: 0.30
	const float W = 11.2; // Default: 11.2
	const float exposureBias = 2.0; // Default: 2.0

	const float whitescale = 1.0 / ((W*(A*W+C*B)+D*E)/(W*(A*W+B)+D*F))-E/F;

	color *= exposureBias;
	color = ((color*(A*color+C*B)+D*E)/(color*(A*color+B)+D*F))-E/F;
	color *= whitescale;

	return;
}

#define curve(x) (((x * (a * x + e * d) + c * f) / (x * (a * x + d) + c * g)) - f / g)
#define lumaCoeff vec3(0.2126, 0.7152, 0.0722)
#define luma(x) dot(x, lumaCoeff)

void mapTones(inout vec3 color) {

    const vec3 a = 3.6            * vec3(1.5, 1.5, 1.5);
    const vec3 b = 17.4            * vec3(1.5, 1.5, 1.5);
    const vec3 c = 0.2            * vec3(1.5, 1.5, 1.5);
    const vec3 d = 0.4            * vec3(1.5, 1.5, 1.5);
    const vec3 e = 0.1            * vec3(1.5, 1.5, 1.5);
    const vec3 f = 0.03            * vec3(1.00, 1.00, 1.00);
    const vec3 g = 0.3            * vec3(1.00, 1.00, 1.00);
    const vec3 h = 0.73            * vec3(1.00, 1.00, 1.00);
    const vec3 k = 0.85         * vec3(1.00, 1.00, 1.00);

    color *= h;

    vec3 desaturated = vec3(luma(color));

    color = mix(desaturated, curve(color), k) / curve(b);
}
