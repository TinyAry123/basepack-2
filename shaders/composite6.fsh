#version 150

/* RENDERTARGETS: 0,11 */

uniform sampler2D colortex0, colortex4, colortex11, colortex13;
uniform float     viewWidth, viewHeight, far, near;
uniform int       frameMod2;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex11Out;

#define TAA // Enable or disable TAA. 

#ifdef TAA
    #define SAMPLERS_CUSTOM_TEX_SIZE viewWidth, viewHeight
    #define TAA_PASS                 2

    #include "lib/common.glsl"
    #include "lib/samplers.glsl"
    #include "lib/TAA/TAAReprojection.glsl"
	#include "lib/TAA/TAABlending.glsl"
#endif

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
    #ifdef TAA
        vec3 TAAColor, TAATemporalColor;
        vec3 reprojectedCoord;

        float depth = LINDEPTH_TO_DEPTH(texelFetch(colortex13, ivec2(uv * bufferSize), 0).r, far, near);

		TAAReprojection(reprojectedCoord, vec3(uv, depth), bufferSize);

        TAABlendingPass2(TAAColor, TAATemporalColor, colortex0, colortex11, colortex4, reprojectedCoord, depth, frameMod2, uv, bufferSize);

        colortex0Out  = vec4(TAAColor, 1.0);
        colortex11Out = vec4(TAATemporalColor, 1.0);
    #else
        colortex0Out  = texelFetch(colortex0, ivec2(uv * bufferSize), 0);
        colortex11Out = vec4(0.0);
    #endif
}