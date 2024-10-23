#version 150

/* RENDERTARGETS: 0,1 */

uniform sampler2D lightmap;
uniform mat3      normalMatrix;
uniform float     viewWidth, viewHeight, alphaTestRef;
uniform int       renderStage;

in vec4 tint;
in vec3 normal;
in vec2 uvLightMap;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex1Out;

#include "lib/common.glsl"

void main() {
	vec4 color = tint;

	if (color.a < alphaTestRef) discard;

	if (renderStage != MC_RENDER_STAGE_DEBUG) color *= texture(lightmap, uvLightMap);

	colortex0Out = color;
	colortex1Out = vec4(normal, 1.0);
}