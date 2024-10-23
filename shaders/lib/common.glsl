#ifndef SAMPLER_TEXELFETCH_CLAMPED
	#define SAMPLER_TEXELFETCH_CLAMPED true

	#define texelFetch(tex, xy, lod)               texelFetch(tex, clamp(xy, ivec2(0, 0), textureSize(tex, 0) - 1), lod)
	#define texelFetchOffset(tex, xy, lod, offset) texelFetch(tex, xy + offset, lod)
#endif

float SRGB_TO_LINRGB(float channel) { // sRGB to linear sRGB. 
	return channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4);
}

vec3 SRGB_TO_LINRGB(vec3 color) { // sRGB to linear sRGB. 
	return vec3(SRGB_TO_LINRGB(color.r), SRGB_TO_LINRGB(color.g), SRGB_TO_LINRGB(color.b));
}

float LINRGB_TO_SRGB(float channel) { // Linear sRGB to sRGB. 
	return channel <= 0.003130804953560371517027863777089783281733746130030959752321981424 ? channel * 12.92 : pow(channel, 1.0 / 2.4) * 1.055 - 0.055;
}

vec3 LINRGB_TO_SRGB(vec3 color) { // Linear sRGB to sRGB. 
	return vec3(LINRGB_TO_SRGB(color.r), LINRGB_TO_SRGB(color.g), LINRGB_TO_SRGB(color.b));
}

const mat3 LINRGB_TO_LMS = mat3( // Linear sRGB to Bjorn Ottoson's linear LMS. 
	 0.4122214708,  0.5363325363,  0.0514459929,
	 0.2119034982,  0.6806995451,  0.1073969566,
	 0.0883024619,  0.2817188376,  0.6299787005
);

const mat3 LMSCBRT_TO_OKLAB = mat3( // Bjorn Ottoson's non-linear LMS to OkLab. 
	 0.2104542553,  0.7936177850, -0.0040720468,
	 1.9779984951, -2.4285922050,  0.4505937099,
	 0.0259040371,  0.7827717662, -0.8086757660
);

vec3 LINRGB_TO_OKLAB(vec3 color) { // Linear sRGB to OkLab. 
	return pow(color * LINRGB_TO_LMS, vec3(1.0 / 3.0)) * LMSCBRT_TO_OKLAB; // OkLab output is in [0, 1], [-1, 1], [-1, 1] for L, a, b respectively. 
}

const mat3 OKLAB_TO_LMSCBRT = mat3( // Inverse from OkLab to non-linear LMS. 
	 1.0,  0.3963377774,  0.2158037573,
	 1.0, -0.1055613458, -0.0638541728,
	 1.0, -0.0894841775, -1.2914855480
);

const mat3 LMS_TO_LINRGB = mat3( // Inverse from linear LMS to linear sRGB. 
	 4.0767416621, -3.3077115913,  0.2309699292,
	-1.2684380046,  2.6097574011, -0.3413193965,
	-0.0041960863, -0.7034186147,  1.7076147010
);

vec3 OKLAB_TO_LINRGB(vec3 color) { // OkLab to linear sRGB. 
	vec3 LMSCBRT = color * OKLAB_TO_LMSCBRT; // OkLab input is in [0, 1], [-1, 1], [-1, 1] for L, a, b respectively. 

	return (LMSCBRT * LMSCBRT * LMSCBRT) * LMS_TO_LINRGB;
}

float LINRGB_TO_OKLUMA(vec3 color) { // Linear sRGB to OkLab luminosity (L). 
	return dot(pow(color * LINRGB_TO_LMS, vec3(1.0 / 3.0)), LMSCBRT_TO_OKLAB[0]);
}

vec2 LINRGB_TO_OKCHROMA(vec3 color) { // Linear sRGB to OkLab chromaticity (a & b). 
	vec3 LMSCBRT = pow(color * LINRGB_TO_LMS, vec3(1.0 / 3.0));

	return vec2(
		dot(LMSCBRT, LMSCBRT_TO_OKLAB[1]),
		dot(LMSCBRT, LMSCBRT_TO_OKLAB[2])
	);
}

float LINRGB_TO_LINLUMA(vec3 color) { // Linear sRGB to linear OkLab luminosity. 
	float lumaOkLab = LINRGB_TO_OKLUMA(color);

	return lumaOkLab * lumaOkLab * lumaOkLab;
}

float OKLAB_TO_LINLUMA(vec3 color) { // OkLab to linear OkLab luminosity. 
	return color.r * color.r * color.r;
}

float DEPTH_TO_LINDEPTH(float depth, float far, float near) { // Depth to linear depth. 
	return far * near / (far + (near - far) * depth);
}

float LINDEPTH_TO_DEPTH(float depth, float far, float near) { // Linear depth to depth. 
	return (far * near / depth - far) / (near - far);
}

const mat3 LINRGB_TO_ACESCG = transpose(mat3(
	 0.6031418648,  0.3263488209,  0.0480322494,
     0.0700483310,  0.9199566727,  0.0127627034,
     0.0221488576,  0.1160833836,  0.9409869783
));

const mat3 ACESCG_TO_LINRGB = transpose(mat3(
	 1.7310585561, -0.6039691407, -0.0801447831,
    -0.1314365771,  1.1347744211, -0.0086903805,
    -0.0245283648, -0.1257564506,  1.0656754216
));

vec3 multiplyColorsFromLinearRGB(vec3 A, vec3 B) {
	return LINRGB_TO_OKLAB(ACESCG_TO_LINRGB * ((LINRGB_TO_ACESCG * A) * (LINRGB_TO_ACESCG * B)));
}