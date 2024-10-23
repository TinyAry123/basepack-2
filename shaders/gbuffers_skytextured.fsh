#version 150

/* RENDERTARGETS: 0,1 */

uniform sampler2D gtexture;
uniform mat3      normalMatrix;

in vec4 tint;
in vec3 normal;
in vec2 uv;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex1Out;

#include "lib/common.glsl"

void main() {
	vec4 color = texture(gtexture, uv) * tint;

	color.rgb = LINRGB_TO_OKLAB(SRGB_TO_LINRGB(color.rgb));

	colortex0Out = color;
	colortex1Out = vec4(normalMatrix * normal, 1.0);
}