#ifndef SAMPLER_TEXELFETCH_CLAMPED
	#define SAMPLER_TEXELFETCH_CLAMPED true

	#define texelFetch(tex, xy, lod)               texelFetch(tex, clamp(xy, ivec2(0, 0), textureSize(tex, 0) - 1), lod)
	#define texelFetchOffset(tex, xy, lod, offset) texelFetch(tex, xy + offset, lod)
#endif

#define SMAA_CONTRAST_ADAPTION_COEFFICIENT 2.0

void SMAAColorEdgeDetection(out vec2 edges, sampler2D colorTex, vec2 uv, vec2 bufferSize) {
    ivec2 texelCoord = ivec2(uv * bufferSize);
    vec4 delta;
    vec3 currentColor;

    vec3 colorCenter = texelFetch(colorTex, texelCoord, 0).rgb;

    currentColor = texelFetchOffset(colorTex, texelCoord, 0, ivec2(-1,  0)).rgb;
    delta.x      = distance(colorCenter, currentColor);                          // Perceptual color space euclidian distance. Probably not scientific but looks good. 

    currentColor = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 0, -1)).rgb;
    delta.y      = distance(colorCenter, currentColor);

    edges = step(0.0625, delta.xy);

    float temp1 = length(delta.xy);

    if (edges.x + edges.y > 0.0) {
        currentColor = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 1,  0)).rgb;
        delta.z      = distance(colorCenter, currentColor);
        
        currentColor = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 0,  1)).rgb;
        delta.w      = distance(colorCenter, currentColor);

        float temp2 = length(delta.zw);

        vec2 maxDelta = max(delta.xy, delta.zw);

        currentColor = texelFetchOffset(colorTex, texelCoord, 0, ivec2(-2,  0)).rgb;
        delta.z      = distance(colorCenter, currentColor);

        currentColor = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 0, -2)).rgb;
        delta.w      = distance(colorCenter, currentColor);

        float temp3 = length(delta.zw);

        maxDelta         = max(maxDelta.xy, delta.zw);
        float finalDelta = max(max(temp1, temp2), temp3); // Better method, using maximum of local difference vector lengths rather than maximum of local x's and y's.

        edges = step(finalDelta, SMAA_CONTRAST_ADAPTION_COEFFICIENT * delta.xy);
    }
}

void SMAADepthEdgeDetection(out vec2 edges, sampler2D depthTex, vec2 uv, vec2 bufferSize) { // Redundant linearisation of depth. Optimise later. 
    ivec2 texelCoord = ivec2(uv * bufferSize);
    vec4  delta;
    float currentDepth;

    float depthCenter = DEPTH_TO_LINDEPTH(texelFetch(depthTex, texelCoord, 0).r, far, near);

    currentDepth = DEPTH_TO_LINDEPTH(texelFetchOffset(depthTex, texelCoord, 0, ivec2(-1,  0)).r, far, near);
    delta.x      = abs(depthCenter - currentDepth);

    currentDepth = DEPTH_TO_LINDEPTH(texelFetchOffset(depthTex, texelCoord, 0, ivec2( 0, -1)).r, far, near);
    delta.y      = abs(depthCenter - currentDepth);

    edges = step(1.0, delta.xy);

    float temp1 = length(delta.xy);

    if (edges.x + edges.y > 0.0) {
        currentDepth = DEPTH_TO_LINDEPTH(texelFetchOffset(depthTex, texelCoord, 0, ivec2( 1,  0)).r, far, near);
        delta.z      = abs(depthCenter - currentDepth);
        
        currentDepth = DEPTH_TO_LINDEPTH(texelFetchOffset(depthTex, texelCoord, 0, ivec2( 0,  1)).r, far, near);
        delta.w      = abs(depthCenter - currentDepth);

        float temp2 = length(delta.zw);

        vec2 maxDelta = max(delta.xy, delta.zw);

        currentDepth = DEPTH_TO_LINDEPTH(texelFetchOffset(depthTex, texelCoord, 0, ivec2(-2,  0)).r, far, near);
        delta.z      = abs(depthCenter - currentDepth);

        currentDepth = DEPTH_TO_LINDEPTH(texelFetchOffset(depthTex, texelCoord, 0, ivec2( 0, -2)).r, far, near);
        delta.w      = abs(depthCenter - currentDepth);

        float temp3 = length(delta.zw);

        maxDelta         = max(maxDelta.xy, delta.zw);
        float finalDelta = max(max(temp1, temp2), temp3);

        edges = step(finalDelta, SMAA_CONTRAST_ADAPTION_COEFFICIENT * delta.xy);
    }
}

void SMAANormalEdgeDetection(out vec2 edges, sampler2D normalTex, vec2 uv, vec2 bufferSize); // Implement later. 