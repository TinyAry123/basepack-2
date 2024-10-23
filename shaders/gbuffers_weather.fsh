#version 150

/* RENDERTARGETS: 0,1 */

uniform sampler2D gtexture, lightmap;
uniform mat3      normalMatrix;
uniform float     viewWidth, viewHeight, alphaTestRef;

in vec4 tint;
in vec3 normal;
in vec2 uv, uvLightMap;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex1Out;

#include "lib/common.glsl"
#include "lib/samplers.glsl"

void main() {
	vec4 color = texture(gtexture, uv) * tint;

	if (color.a < alphaTestRef) discard;
	
	vec4 colorLM = catmullRomTexture2DCustom(lightmap, uvLightMap, ivec2(16, 16));

	color.rgb   = SRGB_TO_LINRGB(color.rgb);
	colorLM.rgb = SRGB_TO_LINRGB(colorLM.rgb);

	color.rgb = multiplyColorsFromLinearRGB(color.rgb, colorLM.rgb);

	colortex0Out = color;
	colortex1Out = vec4(normalMatrix * normal, 1.0);
}