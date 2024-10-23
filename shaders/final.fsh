#version 120

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0, colortex13;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;

#define POST_ZOOM 1.0 // Zooming for pixel-peeping. [0.5 1.0 2.0 4.0 8.0 16.0 32.0 64.0]

#include "lib/common.glsl"

#if ZOOM != 1.0
	#define SAMPLERS_CUSTOM_TEX_SIZE viewWidth, viewHeight

	#include "lib/samplers.glsl"
#endif

vec2 bufferSize = vec2(viewWidth, viewHeight);

float vigIntegrated(float x) {
	float xC = x - 0.5;

	return 4.0 * xC * xC * xC / 3.0;
}

float vigPixelArea(vec2 uv) {
	float a = uv.x - 0.5 / bufferSize.x;
	float b = uv.x + 0.5 / bufferSize.x;

	return vigIntegrated(b) - vigIntegrated(a);
}

void main() {
	#if ZOOM == 1
		vec4 color = texelFetch(colortex0, ivec2(uv * bufferSize), 0);
	#else
		vec4 color = catmullRomTexture2D(colortex0, (uv - 0.5) / POST_ZOOM + 0.5);
	#endif

	colortex0Out = vec4(LINRGB_TO_SRGB(OKLAB_TO_LINRGB(color.rgb)), 1.0);
}