#version 150 compatibility

uniform mat4  dhProjection;
uniform float viewWidth, viewHeight;
uniform int   frameMod2;

out vec4 blockColor;
out vec2 uvLightMap;

#define TAA // Enable or disable TAA. 

#ifdef TAA
	#include "lib/TAA/TAAJitter.glsl"
#endif

void main() {
    gl_Position = ftransform();

    #ifdef TAA
		TAAJitter(gl_Position.xy, gl_Position.w, frameMod2, ivec2(viewWidth, viewHeight));
	#endif

    blockColor = gl_Color;
    uvLightMap = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}