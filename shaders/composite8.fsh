#version 150

/* RENDERTARGETS: 0,8 */

uniform sampler2D colortex0;
uniform mat4      gbufferPreviousModelView, gbufferPreviousProjection;
uniform vec3      previousCameraPosition;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex8Out;

#define AMD_CAS // Enable or disable CAS. 

#ifdef AMD_CAS
	#include "lib/CAS.glsl"
#endif

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
	ivec2 texelCoord = ivec2(uv * bufferSize);

	vec4 color = texelFetch(colortex0, texelCoord, 0);

	#ifdef AMD_CAS
		CAS(color.rgb, colortex0, uv, bufferSize);
	#endif

	colortex0Out = color;
	
	ivec2 clampedTexel = min(texelCoord, 3);

	colortex8Out = vec4(
		gbufferPreviousModelView[clampedTexel.y][clampedTexel.x], 
	    gbufferPreviousProjection[clampedTexel.y][clampedTexel.x], 
		previousCameraPosition.xyzz[clampedTexel.y], 
		0.0
	); 		// Funny monkey swizzle 4 floats camera pos
}