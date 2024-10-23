#version 150

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;

#define TONEMAP // Enable or disable tonemapping. 

#include "lib/optifineSettings.glsl"
#include "lib/common.glsl" 

vec2 bufferSize = vec2(viewWidth, viewHeight);

#ifdef TONEMAP
	#include "lib/tonemap.glsl"
#endif

void main() {
	ivec2 texelCoord = ivec2(uv * bufferSize);

	#ifdef TONEMAP
        vec4 color = texelFetch(colortex0, texelCoord, 0);

        colortex0Out = vec4(tonemapOkLab(color.rgb), color.a);
    #else
        colortex0Out = texelFetch(colortex0, texelCoord, 0);
    #endif
}