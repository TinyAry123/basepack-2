#version 150

/* RENDERTARGETS: 2 */

uniform sampler2D colortex0, depthtex0, depthtex1;
uniform float     viewWidth, viewHeight, far, near;

in vec2 uv;

layout(location = 0) out vec4 colortex2Out;

#define SMAA // Enable or disable SMAA. 

#ifdef SMAA
    #include "lib/common.glsl"
    #include "lib/SMAA/SMAAEdgeDetection.glsl"
#endif

vec2 bufferSize = vec2(viewWidth, viewHeight);

void main() {
    #ifdef SMAA
        vec4 SMAAEdges;

        SMAAColorEdgeDetection(SMAAEdges.rg, colortex0, uv, bufferSize);
        SMAADepthEdgeDetection(SMAAEdges.ba, depthtex1, uv, bufferSize);

        colortex2Out = vec4(max(SMAAEdges.rg, SMAAEdges.ba), 0.0, 0.0);
    #else
        colortex2Out = vec4(0.0);
    #endif
}