#version 150

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
    colortex0Out = texelFetch(colortex0, ivec2(uv * bufferSize), 0);
}