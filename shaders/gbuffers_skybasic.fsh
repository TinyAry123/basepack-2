#version 150

/* RENDERTARGETS: 0,1 */

uniform mat4  gbufferModelView, gbufferProjectionInverse;
uniform mat3  normalMatrix;
uniform vec3  skyColor, fogColor;
uniform float viewWidth, viewHeight;

in vec3 starColor, normal;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex1Out;

#include "lib/common.glsl"

vec3 calculateSkyColor(vec3 viewPositionNormalised) {
	float upDot     = dot(viewPositionNormalised, gbufferModelView[1].xyz);
	float fogFactor = max(upDot, 0.0);
	
	return mix(skyColor, fogColor, 0.25 / (fogFactor * fogFactor + 0.25));
}

void main() {
	vec3 color = starColor.r > 0.0 && starColor.r == starColor.g && starColor.g == starColor.b ? starColor : calculateSkyColor(normalize((gbufferProjectionInverse * vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0)).xyz));

	color = LINRGB_TO_OKLAB(SRGB_TO_LINRGB(color));

	colortex0Out = vec4(color, 1.0);
	colortex1Out = vec4(normalMatrix * normal, 1.0);
}