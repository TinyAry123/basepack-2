#version 150 compatibility

/* RENDERTARGETS: 0 */

uniform sampler2D lightmap, depthtex0;
uniform float     viewWidth, viewHeight;

in vec4 blockColor;
in vec2 uvLightMap;

layout(location = 0) out vec4 colortex0Out;

#define SAMPLERS_CUSTOM_TEX_SIZE viewWidth, viewHeight

#include "lib/samplers.glsl"
#include "lib/common.glsl"

void main() {
    if (blockColor.a < 0.1) discard;

    if (texelFetch(depthtex0, ivec2(gl_FragCoord.xy), 0).r != 1.0) discard;

    vec4 color   = blockColor;
    vec4 colorLM = texelFetch(lightmap, ivec2(uvLightMap * 16.0), 0);

    color.rgb   = SRGB_TO_LINRGB(color.rgb);
    colorLM.rgb = SRGB_TO_LINRGB(colorLM.rgb);

    color.rgb = multiplyColorsFromLinearRGB(color.rgb, colorLM.rgb);

    colortex0Out = color;
}