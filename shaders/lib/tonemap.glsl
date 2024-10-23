#define TONEMAP_SATURATION 1.0000 // Saturation filter. [0.0000 0.0625 0.1250 0.1875 0.2500 0.3125 0.3750 0.4375 0.5000 0.5625 0.6250 0.6875 0.7500 0.8125 0.8750 0.9375 1.0000]

float tonemap(float channel) {
    channel = max(channel, 0.0);
    
    return clamp(channel * (2.51 * channel + 0.03) / (channel * (2.43 * channel + 0.59) + 0.14), 0.0, 1.0);
}

vec3 tonemap(vec3 color) {
    return vec3(tonemap(color.r), tonemap(color.g), tonemap(color.b));
}

vec3 tonemapOkLab(vec3 color) {
    vec3 tonemapped = vec3(LINRGB_TO_OKLAB(tonemap(OKLAB_TO_LINRGB(color))));

    return vec3(tonemapped.r, TONEMAP_SATURATION * tonemapped.gb);
}