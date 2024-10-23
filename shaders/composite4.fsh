#version 120

/* RENDERTARGETS: 4,6 */

uniform sampler2D colortex6, depthtex2;
uniform float     viewWidth, viewHeight, far, near;

in vec2 uv;

layout(location = 0) out vec4 colortex4Out;
layout(location = 1) out vec4 colortex6Out;

#define SMAA // Enable or disable SMAA. 
#define TAA  // Enable or disable TAA. 

#ifdef TAA
	#include "lib/common.glsl"
	#include "lib/TAA/TAAReprojection.glsl"
#endif

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
	#ifdef TAA
		float depth = texelFetch(colortex6, ivec2(uv * bufferSize), 0).r;
		vec3 reprojectedScreenPosition;

		TAAReprojection(reprojectedScreenPosition, vec3(uv, depth), bufferSize);

		colortex4Out = vec4(reprojectedScreenPosition.xy, 0.0, 0.0);
		colortex6Out = vec4(DEPTH_TO_LINDEPTH(depth, far, near), DEPTH_TO_LINDEPTH(reprojectedScreenPosition.z, far, near), 0.0, 0.0);
	#else
		colortex4Out = vec4(0.0);
		colortex6Out = vec4(0.0);
	#endif
}