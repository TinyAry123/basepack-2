#version 150

/* RENDERTARGETS: 2,6 */

uniform sampler2D colortex2, colortex14, colortex15, depthtex0, depthtex1;
uniform float     viewWidth, viewHeight, far, near;

in vec2 uv;

layout(location = 0) out vec4 colortex2Out;
layout(location = 1) out vec4 colortex6Out;

#define SMAA // Enable or disable SMAA. 
#define TAA  // Enable or disable TAA. 

#ifdef SMAA
	#include "lib/SMAA/SMAABlendingWeightCalculation.glsl"
#endif

#ifdef TAA
	#include "lib/common.glsl"
#endif

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
	#ifdef SMAA
		vec4 SMAAWeights;

		SMAABlendingWeightCalculation(SMAAWeights, colortex2, colortex14, colortex15, uv, bufferSize);

		colortex2Out = SMAAWeights;
	#else
		colortex2Out = vec4(0.0);
	#endif

	#ifdef TAA
		ivec2 texelCoord = ivec2(uv * bufferSize);

		#ifdef SMAA
			float depth = 0.5 * (texelFetch(depthtex0, texelCoord, 0).r + texelFetch(depthtex1, texelCoord, 0).r);

			colortex6Out = vec4(DEPTH_TO_LINDEPTH(depth, far, near), 0.0, 0.0, 0.0);
		#else
			float depth = 0.5 * (texelFetch(depthtex0, texelCoord, 0).r + texelFetch(depthtex1, texelCoord, 0).r);

			colortex6Out = vec4(depth, 0.0, 0.0, 0.0);
		#endif
	#else
		colortex6Out = vec4(0.0);
	#endif
}