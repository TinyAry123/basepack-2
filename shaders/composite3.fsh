#version 150

/* RENDERTARGETS: 0,6 */

uniform sampler2D colortex0, colortex2, colortex6;
uniform float     viewWidth, viewHeight, far, near;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex6Out;

#define SMAA // Enable or disable SMAA. 
#define TAA  // Enable or disable TAA. 

#ifdef SMAA
	#define SAMPLERS_CUSTOM_TEX_SIZE viewWidth, viewHeight

	#include "lib/common.glsl"
    #include "lib/samplers.glsl"
	#include "lib/SMAA/SMAANeighborhoodBlending.glsl"
#endif

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
	#ifdef SMAA
		vec3 SMAAColor;
		
		#ifdef TAA
			float SMAADepth;

			SMAANeighborhoodBlending(SMAAColor, SMAADepth, colortex0, colortex6, colortex2, uv, bufferSize);

			colortex6Out = vec4(LINDEPTH_TO_DEPTH(SMAADepth, far, near), 0.0, 0.0, 0.0);
		#else
			SMAANeighborhoodBlending(SMAAColor, colortex0, colortex2, uv, bufferSize);

			colortex6Out = vec4(0.0);
		#endif

		colortex0Out = vec4(SMAAColor, 1.0);
	#else
		colortex0Out = texelFetch(colortex0, ivec2(uv * bufferSize), 0);

		#ifdef TAA
			colortex6Out = texelFetch(colortex6, ivec2(uv * bufferSize), 0);
		#else
			colortex6Out = vec4(0.0);
		#endif
	#endif
}