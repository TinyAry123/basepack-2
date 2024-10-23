#ifndef SAMPLER_TEXELFETCH_CLAMPED
	#define SAMPLER_TEXELFETCH_CLAMPED true

	#define texelFetch(tex, xy, lod)               texelFetch(tex, clamp(xy, ivec2(0, 0), textureSize(tex, 0) - 1), lod)
	#define texelFetchOffset(tex, xy, lod, offset) texelFetch(tex, xy + offset, lod)
#endif

#define SORTING_ARRAY_SIZE 5
#define SORTING_TYPE       float

#include "../sorting.glsl"

const ivec2[12] neighborhoodOffsets = ivec2[12](
    ivec2( 1,  0),
    ivec2( 0,  1),
    ivec2(-1,  0),
    ivec2( 0, -1),
    ivec2( 1, -1),
    ivec2( 2,  0),
    ivec2( 1,  1),
    ivec2( 0,  2),
    ivec2(-1,  1),
    ivec2(-2,  0),
    ivec2(-1, -1),
    ivec2( 0, -2)
);

float catmullRom(float c, float d, float t) { // Simplified where samples a == b == c. 
    return c + 0.5 * t * t * (c - d + t * (d - c));
}

// These algorithms need to really be optimised soon. Also many buffers are used unnecessarily. 

void TAABlendingPass1(out vec3 color, out vec3 temporalColor, out float depth, out float temporalDepth, sampler2D currentColorTex, sampler2D previousColorTex, sampler2D currentDepthTex, sampler2D previousDepthTex, sampler2D previousUvTex, int frameMod2, vec2 uv, vec2 bufferSize) {
    ivec2 texelCoord = ivec2(uv * bufferSize);
    
    vec2 previousUv = texelFetch(previousUvTex, texelCoord, 0).xy;

    vec3 currentColor   = texelFetch(currentColorTex, texelCoord, 0).rgb;
    vec3 previousColor  = catmullRomTexture2D(previousColorTex, previousUv).rgb;
    float currentDepth  = texelFetch(currentDepthTex, texelCoord, 0).r;
    float previousDepth = catmullRomTexture2D(previousDepthTex, previousUv).r;

    int direction = 1 - 2 * frameMod2; // 0 --> 1, 1 --> -1. 

    vec2 previousUv2 = texelFetch(previousUvTex, texelCoord - direction, 0).xy;

    vec3 currentColor2   = texelFetch(currentColorTex, texelCoord + direction, 0).rgb;
    vec3 previousColor2  = catmullRomTexture2D(previousColorTex, previousUv2).rgb;
    float currentDepth2  = texelFetch(currentDepthTex, texelCoord + direction, 0).r;
    float previousDepth2 = catmullRomTexture2D(previousDepthTex, previousUv2).r;

    vec2 unjUv  = uv - 0.25 * direction / bufferSize;
    vec2 unjUv2 = uv + 0.25 * direction / bufferSize;

    vec2 t = catmullRomTexture2D(previousUvTex, unjUv).xy;

    vec3 color1 = catmullRomTexture2D(currentColorTex, unjUv2).rgb;
    vec3 color2 = catmullRomTexture2D(previousColorTex, t).rgb;
    float depth1 = catmullRomTexture2D(currentDepthTex, unjUv2).r;
    float depth2 = catmullRomTexture2D(previousDepthTex, t).r;

    float colorDifference    = distance(color1, color2);
    float colorDifferenceMin = colorDifference;
    vec2 temp1;
    vec2 temp2;
    float differences[5];
    differences[0] = colorDifference;

    for (int i = 0; i < 4; i++) {
        temp2 = unjUv + neighborhoodOffsets[i] / bufferSize;

        temp1 = catmullRomTexture2D(previousUvTex, temp2).xy;

        differences[i + 1] = distance(catmullRomTexture2D(currentColorTex, unjUv2 + neighborhoodOffsets[i] / bufferSize).rgb, catmullRomTexture2D(previousColorTex, temp1).rgb);
        colorDifferenceMin = min(colorDifferenceMin, differences[i]);
    }

    sortArray(differences);

    vec2 previousUvData = (previousUv * bufferSize - 0.5) / (bufferSize - 1.0);

    float uvDisocclusion = float(previousUvData != clamp(previousUvData, 0.0, 1.0));

    float blendingWeight = smoothstep(0.0625, 0.25, catmullRom(differences[0], differences[0], differences[1], differences[2], 0.75));
    blendingWeight       = max(blendingWeight, uvDisocclusion);

    color         = catmullRom(currentColor2, previousColor, currentColor, previousColor2, 0.5);
    color         = mix(color, color1, blendingWeight);
    temporalColor = currentColor;
    depth         = catmullRom(currentDepth2, previousDepth, currentDepth, previousDepth2, 0.5);
    depth         = mix(depth, depth1, blendingWeight);
    temporalDepth = currentDepth;
}

#define TAA_FILMIC_FILTER         // Enable or disable TAA "filmic" temporal filter. 
#define TAA_FILMIC_STRENGTH 1.000 // Strength of the TAA "filmic" temporal filter. [0.125 0.250 0.375 0.500 0.625 0.750 0.875 1.000]

#if TAA_PASS == 1
    uniform float far, near;
#endif

void TAABlendingPass2(out vec3 color, out vec3 temporalColor, sampler2D currentHistoryTex, sampler2D previousHistoryTex, sampler2D previousUvTex, vec3 reprojectedCoord, float depth, int frameMod2, vec2 uv, vec2 bufferSize) {
    ivec2 texelCoord = ivec2(uv * bufferSize);

    #ifdef TAA_FILMIC_FILTER
        vec2 previousUv = reprojectedCoord.xy;

        vec3 currentColor  = texelFetch(currentHistoryTex, texelCoord, 0).rgb;
        vec3 previousColor = catmullRomTexture2D(previousHistoryTex, previousUv).rgb;

        vec2 previousUvData = (previousUv * bufferSize - 0.5) / (bufferSize - 1.0);

        float uvDisocclusion = float(previousUvData != clamp(previousUvData, 0.0, 1.0));

        float blendingWeight = smoothstep(0.0625, 0.25, distance(currentColor, previousColor));
        blendingWeight       = max(blendingWeight, uvDisocclusion);

        color         = mix(previousColor, currentColor, mix(1.0, blendingWeight * 0.5 + 0.5, TAA_FILMIC_STRENGTH));
        color         = clamp(color, vec3(0.0, -1.0, -1.0), vec3(1.0, 1.0, 1.0));                                    // Sometimes errors are accumulated. 
        temporalColor = color;
    #else
        color         = texelFetch(currentHistoryTex, texelCoord, 0).rgb;
        temporalColor = vec3(0.0);
    #endif
}