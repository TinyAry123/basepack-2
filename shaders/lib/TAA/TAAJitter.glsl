uniform int frameMod4, frameMod16;

const vec2 TAAJitterOffsets[4] = 2.0 * vec2[4]( // Doubled offsets for [-w, w] range after perspective multiply. 
    vec2( 0.25,  0.25),
    vec2(-0.25, -0.25),
    vec2( 0.25, -0.25),
    vec2(-0.25,  0.25)
);

void TAAJitter(inout vec2 positionXY, float perspectiveScalar, int frameMod2, vec2 bufferSize) { // Implement jitter later. 
    positionXY += perspectiveScalar * TAAJitterOffsets[frameMod2] / bufferSize;
}