// short edges
vec4 sampleCenter     = sampleOffseted(colortex0, texCoord.xy, vec2( 0.0,  0.0) );
vec4 sampleHorizNeg0   = sampleOffseted(colortex0, texCoord.xy, vec2(-1.5,  0.0) );
vec4 sampleHorizPos0   = sampleOffseted(colortex0, texCoord.xy, vec2( 1.5,  0.0) );
vec4 sampleVertNeg0   = sampleOffseted(colortex0, texCoord.xy, vec2( 0.0, -1.5) );
vec4 sampleVertPos0   = sampleOffseted(colortex0, texCoord.xy, vec2( 0.0,  1.5) );

vec4 sumHoriz         = sampleHorizNeg0 + sampleHorizPos0;
vec4 sumVert          = sampleVertNeg0  + sampleVertPos0;

vec4 diffToCenterHoriz = abs( sumHoriz - (2.0 * sampleCenter) ) / 2.0;
vec4 diffToCenterVert  = abs( sumHoriz - (2.0 * sampleCenter) ) / 2.0;

float valueEdgeHoriz    = avg( diffToCenterHoriz.xyz );
float valueEdgeVert     = avg( diffToCenterVert.xyz );

float edgeDetectHoriz   = clamp( (3.0 * valueEdgeHoriz) - 0.1,0.0,1.0);
float edgeDetectVert    = clamp( (3.0 * valueEdgeVert)  - 0.1,0.0,1.0);

vec4 avgHoriz         	= ( sumHoriz + sampleCenter) / 4.0;
vec4 avgVert            = ( sumVert  + sampleCenter) / 4.0;

float valueHoriz        = avg( avgHoriz.xyz );
float valueVert         = avg( avgVert.xyz );

float blurAmountHoriz   = clamp( edgeDetectHoriz / valueHoriz ,0.0,1.0);
float blurAmountVert    = clamp( edgeDetectVert  / valueVert ,0.0,1.0);

vec4 aaResult         	= mix( sampleCenter,  avgHoriz, blurAmountHoriz );
aaResult                = mix( aaResult,       avgVert,  blurAmountVert );

aaResult = mix(aaResult, texture2D(colortex4, texCoord), clamp(length(vec2(blurAmountVert, blurAmountHoriz)), 0, 1) * 0.95);
