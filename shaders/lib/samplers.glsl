#define texelFetchClamped(tex, xy, lod)               texelFetch(tex, clamp(xy, ivec2(0, 0), ivec2(SAMPLERS_CUSTOM_TEX_SIZE) - 1), lod)
#define texelFetchClampedOffset(tex, xy, lod, offset) texelFetchClamped(tex, xy + offset, lod)

#ifndef SAMPLERS_CUSTOM_TEX_SIZE
    #define SAMPLERS_CUSTOM_TEX_SIZE viewWidth, viewHeight // Define any texture size. Defaults to viewWidth and viewHeight uniforms. 
    #define SAMPLERS_COMPATIBILITY   true                  // Choose to define if variable texture size is used within same shader program. Defaults to defined for compatability with older programs. 
#endif

vec4 catmullRom(vec4 a, vec4 b, vec4 c, vec4 d, float t) { // Interpolates in-between samples b and c using t [0, 1]. 
    return b + t * (0.5 * (c - a) + t * (a + 2.0 * c - 2.5 * b - 0.5 * d + t * (1.5 * (b - c) + 0.5 * (d - a))));
}

vec3 catmullRom(vec3 a, vec3 b, vec3 c, vec3 d, float t) { // Interpolates in-between samples b and c using t [0, 1]. 
    return b + t * (0.5 * (c - a) + t * (a + 2.0 * c - 2.5 * b - 0.5 * d + t * (1.5 * (b - c) + 0.5 * (d - a))));
}

vec2 catmullRom(vec2 a, vec2 b, vec2 c, vec2 d, float t) { // Interpolates in-between samples b and c using t [0, 1]. 
    return b + t * (0.5 * (c - a) + t * (a + 2.0 * c - 2.5 * b - 0.5 * d + t * (1.5 * (b - c) + 0.5 * (d - a))));
}

float catmullRom(float a, float b, float c, float d, float t) { // Interpolates in-between samples b and c using t [0, 1]. 
    return b + t * (0.5 * (c - a) + t * (a + 2.0 * c - 2.5 * b - 0.5 * d + t * (1.5 * (b - c) + 0.5 * (d - a))));
}

vec4 catmullRomTexture2D(sampler2D tex, vec2 uv) { // Full 16-tap filter actually gives better temporal stability than the 9-tap or 5-tap approximation. 
    vec2 xy      = uv * vec2(SAMPLERS_CUSTOM_TEX_SIZE) - 0.5;
    vec2 weights = fract(xy);

    ivec2 xy00 = ivec2(floor(xy)) - 1;

    vec4 color00 = texelFetchClamped(tex, xy00, 0);
    vec4 color01 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 0,  1));
    vec4 color02 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 0,  2));
    vec4 color03 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 0,  3));
    vec4 color10 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 1,  0));
    vec4 color11 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 1,  1));
    vec4 color12 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 1,  2));
    vec4 color13 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 1,  3));
    vec4 color20 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 2,  0));
    vec4 color21 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 2,  1));
    vec4 color22 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 2,  2));
    vec4 color23 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 2,  3));
    vec4 color30 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 3,  0));
    vec4 color31 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 3,  1));
    vec4 color32 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 3,  2));
    vec4 color33 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 3,  3));

    vec4 interp0Y = catmullRom(color00, color01, color02, color03, weights.y);
    vec4 interp1Y = catmullRom(color10, color11, color12, color13, weights.y);
    vec4 interp2Y = catmullRom(color20, color21, color22, color23, weights.y);
    vec4 interp3Y = catmullRom(color30, color31, color32, color33, weights.y);

    return catmullRom(interp0Y, interp1Y, interp2Y, interp3Y, weights.x);
}

#undef texelFetchClamped
#define texelFetchClamped(tex, xy, lod) vec4(LINRGB_TO_OKLAB(SRGB_TO_LINRGB(texelFetch(tex, clamp(xy, ivec2(0, 0), ivec2(SAMPLERS_CUSTOM_TEX_SIZE) - 1), lod).rgb)), 1.0) // Nooby method using catmullRomTexture2DCustom as a temporary wrapper for interpolating lightmaps in a different color space until I can code compute shaders bruh. 

#ifdef SAMPLERS_COMPATIBILITY
    vec4 catmullRomTexture2DCustom(sampler2D tex, vec2 uv, vec2 texSize) { // Deprecated sampler. Programs that don't have SAMPLERS_CUSTOM_TEX_SIZE defined may have used this. 
        vec2 xy      = uv * texSize - 0.5;
        vec2 weights = fract(xy);

        ivec2 xy00 = ivec2(floor(xy)) - 1;

        vec4 color00 = texelFetchClamped(tex, xy00, 0);
        vec4 color01 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 0,  1));
        vec4 color02 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 0,  2));
        vec4 color03 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 0,  3));
        vec4 color10 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 1,  0));
        vec4 color11 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 1,  1));
        vec4 color12 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 1,  2));
        vec4 color13 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 1,  3));
        vec4 color20 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 2,  0));
        vec4 color21 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 2,  1));
        vec4 color22 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 2,  2));
        vec4 color23 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 2,  3));
        vec4 color30 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 3,  0));
        vec4 color31 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 3,  1));
        vec4 color32 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 3,  2));
        vec4 color33 = texelFetchClampedOffset(tex, xy00, 0, ivec2( 3,  3));

        vec4 interp0Y = catmullRom(color00, color01, color02, color03, weights.y);
        vec4 interp1Y = catmullRom(color10, color11, color12, color13, weights.y);
        vec4 interp2Y = catmullRom(color20, color21, color22, color23, weights.y);
        vec4 interp3Y = catmullRom(color30, color31, color32, color33, weights.y);

        return vec4(LINRGB_TO_SRGB(OKLAB_TO_LINRGB(catmullRom(interp0Y, interp1Y, interp2Y, interp3Y, weights.x).rgb)), 1.0);
    }
#endif

#undef texelFetchClamped
#define texelFetchClamped(tex, xy, lod) texelFetch(tex, clamp(xy, ivec2(0, 0), ivec2(SAMPLERS_CUSTOM_TEX_SIZE) - 1), lod)