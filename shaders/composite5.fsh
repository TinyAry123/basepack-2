#version 150

/* RENDERTARGETS: 0,3,12,13 */

uniform sampler2D colortex0, colortex3, colortex4, colortex6, colortex12;
uniform float     viewWidth, viewHeight;
uniform int       frameMod2;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex3Out;
layout(location = 2) out vec4 colortex12Out;
layout(location = 3) out vec4 colortex13Out;

#define TAA // Enable or disable TAA. 

#ifdef TAA
    #define SAMPLERS_CUSTOM_TEX_SIZE viewWidth, viewHeight
    #define TAA_PASS                 1

    #include "lib/common.glsl"
    #include "lib/samplers.glsl"
	#include "lib/TAA/TAABlending.glsl"
#endif

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
    #ifdef TAA
        vec3  TAAColor, TAATemporalColor;
        float TAADepth, TAATemporalDepth;

        TAABlendingPass1(TAAColor, TAATemporalColor, TAADepth, TAATemporalDepth, colortex0, colortex3, colortex6, colortex12, colortex4, frameMod2, uv, bufferSize);

        colortex0Out  = vec4(TAAColor, 1.0);
        colortex3Out  = vec4(TAATemporalColor, 1.0);
        colortex12Out = vec4(TAATemporalDepth, 0.0, 0.0, 0.0);
        colortex13Out = vec4(TAADepth, 0.0, 0.0, 0.0);
    #else
        colortex0Out  = texelFetch(colortex0, ivec2(uv * bufferSize), 0);
        colortex3Out  = vec4(0.0);
        colortex12Out = vec4(0.0);
        colortex13Out = vec4(0.0);
    #endif
}