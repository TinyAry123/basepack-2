#ifndef SAMPLER_TEXELFETCH_CLAMPED
	#define SAMPLER_TEXELFETCH_CLAMPED true

	#define texelFetch(tex, xy, lod)               texelFetch(tex, clamp(xy, ivec2(0, 0), textureSize(tex, 0) - 1), lod)
	#define texelFetchOffset(tex, xy, lod, offset) texelFetch(tex, xy + offset, lod)
#endif

#define CAS_SHARPNESS 0.0625

void CAS(inout vec3 color, sampler2D colorTex, vec2 uv, vec2 bufferSize) { // AMD FidelityFX Contrast Adaptive Sharpening, adapted for OkLab color space (still needs optimisation). 
	ivec2 texelCoord = ivec2(uv * bufferSize);

	vec3 d = texelFetchOffset(colorTex, texelCoord, 0, ivec2(-1,  0)).rgb;
	vec3 f = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 1,  0)).rgb;
	vec3 b = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 0, -1)).rgb;
	vec3 h = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 0,  1)).rgb;

	vec3 eLin = color;
	vec3 dLin = d;
	vec3 fLin = f;
	vec3 bLin = b;
	vec3 hLin = h;
	vec3 aLin = pow(texelFetchOffset(colorTex, texelCoord, 0, ivec2(-1, -1)).rgb, ivec3(1));
	vec3 gLin = pow(texelFetchOffset(colorTex, texelCoord, 0, ivec2(-1,  1)).rgb, ivec3(1));
	vec3 iLin = pow(texelFetchOffset(colorTex, texelCoord, 0, ivec2( 1,  1)).rgb, ivec3(1));
	vec3 cLin = pow(texelFetchOffset(colorTex, texelCoord, 0, ivec2( 1, -1)).rgb, ivec3(1));

	eLin.gb = abs(eLin.gb);
	dLin.gb = abs(dLin.gb);
	fLin.gb = abs(fLin.gb);
	bLin.gb = abs(bLin.gb);
	hLin.gb = abs(hLin.gb);
	aLin.gb = abs(aLin.gb);
	gLin.gb = abs(gLin.gb);
	iLin.gb = abs(iLin.gb);
	cLin.gb = abs(cLin.gb);

	float minLuma =  min(min(min(dLin.r, eLin.r), min(fLin.r, bLin.r)), hLin.r);
	float maxLuma =  max(max(max(dLin.r, eLin.r), max(fLin.r, bLin.r)), hLin.r);
	minLuma       += min(minLuma, min(min(aLin.r, cLin.r), min(gLin.r, iLin.r)));
	maxLuma       += max(maxLuma, max(max(aLin.r, cLin.r), max(gLin.r, iLin.r)));

	float minChromaA =  min(min(min(dLin.g, eLin.g), min(fLin.g, bLin.g)), hLin.g);
	float maxChromaA =  max(max(max(dLin.g, eLin.g), max(fLin.g, bLin.g)), hLin.g);
	minChromaA       += min(minChromaA, min(min(aLin.g, cLin.g), min(gLin.g, iLin.g)));
	maxChromaA       += max(maxChromaA, max(max(aLin.g, cLin.g), max(gLin.g, iLin.g)));

	float minChromaB =  min(min(min(dLin.b, eLin.b), min(fLin.b, bLin.b)), hLin.b);
	float maxChromaB =  max(max(max(dLin.b, eLin.b), max(fLin.b, bLin.b)), hLin.b);
	minChromaB       += min(minChromaB, min(min(aLin.b, cLin.b), min(gLin.b, iLin.b)));
	maxChromaB       += max(maxChromaB, max(max(aLin.b, cLin.b), max(gLin.b, iLin.b)));

	float weightLuma    = -CAS_SHARPNESS * clamp(sqrt(min(minLuma, 2.0 - maxLuma) / maxLuma), 0.0, 1.0);
	float weightChromaA = -CAS_SHARPNESS * clamp(sqrt(min(minChromaA, 2.0 - maxChromaA) / maxChromaA), 0.0, 1.0);
	float weightChromaB = -CAS_SHARPNESS * clamp(sqrt(min(minChromaB, 2.0 - maxChromaB) / maxChromaB), 0.0, 1.0);

	color.r = clamp(((b.r + d.r + f.r + h.r) * weightLuma + color.r) / (4.0 * weightLuma + 1.0), 0.0, 1.0);
	color.g = clamp(((b.g + d.g + f.g + h.g) * weightChromaA + color.g) / (4.0 * weightChromaA + 1.0), -1.0, 1.0);
	color.b = clamp(((b.b + d.b + f.b + h.b) * weightChromaB + color.b) / (4.0 * weightChromaB + 1.0), -1.0, 1.0);
}