#version 150

uniform mat4  modelViewMatrix, projectionMatrix;
uniform vec3  chunkOffset;
uniform float viewWidth, viewHeight;
uniform int   frameMod2;

in vec4  vaColor;
in vec3  vaPosition, vaNormal;
in vec2  vaUV0;
in ivec2 vaUV2;

out vec4  tint;
out vec3  normal;
out vec2  uv, uvLightMap;
out float depth;

#define TAA // Enable or disable TAA. 

#ifdef TAA
	#include "lib/TAA/TAAJitter.glsl"
#endif

mat4 modelViewProjectionMatrix = projectionMatrix * modelViewMatrix;

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
	gl_Position = modelViewProjectionMatrix * vec4(vaPosition + chunkOffset, 1.0);

	#ifdef TAA
		TAAJitter(gl_Position.xy, gl_Position.w, frameMod2, bufferSize);
	#endif

	tint       = vaColor;
	normal     = normalize(vaNormal);
	uv         = vaUV0;
	uvLightMap = (vaUV2 + 8.0) / 256.0;
	depth      = gl_Position.z;
}