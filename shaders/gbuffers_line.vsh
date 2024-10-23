#version 150

uniform mat4  modelViewMatrix, projectionMatrix;
uniform float viewWidth, viewHeight;
uniform int   frameMod2;

in vec4 vaColor;
in vec3 vaPosition, vaNormal;

out vec4 tint;
out vec3 normal;

#define TAA // Enable or disable TAA. 

#ifdef TAA
	#include "lib/TAA/TAAJitter.glsl"
#endif

const mat4 viewScaleMatrix = mat4(
	0.99609375, 0.0,        0.0,        0.0,
	0.0,        0.99609375, 0.0,        0.0,
	0.0,        0.0,        0.99609375, 0.0,
	0.0,        0.0,        0.0,        1.0
);

mat4 modelViewProjectionMatrix = projectionMatrix * viewScaleMatrix * modelViewMatrix;

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
	vec4 lineStartPosition = modelViewProjectionMatrix * vec4(vaPosition, 1.0);
	vec4 lineEndPosition   = modelViewProjectionMatrix * vec4(vaPosition + vaNormal, 1.0);

	vec3 startNDC = lineStartPosition.xyz / lineStartPosition.w;

	vec2 lineScreenDirection = normalize(bufferSize * (lineEndPosition.xy / lineEndPosition.w - startNDC.xy));
	vec2 lineOffset          = 2.0 * vec2(-lineScreenDirection.y, lineScreenDirection.x) / bufferSize;

	lineOffset *= step(0.0, lineOffset.x) * 2.0 - 1.0;
	lineOffset *= 1 - 2 * (gl_VertexID % 2);

	gl_Position = vec4((startNDC + vec3(lineOffset, 0.0)) * lineStartPosition.w, lineStartPosition.w);

	#ifdef TAA
		TAAJitter(gl_Position.xy, gl_Position.w, frameMod2, bufferSize);
	#endif

	tint   = vaColor;
	normal = normalize(vaNormal);
}