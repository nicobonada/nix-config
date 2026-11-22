// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Barrulus
// Ported from bumbriel 1dafcac5; current Umbriel spectrum input.
// Recolors the native ring; does not add a translucent halo.

// Visual activity from all 64 normalized bands; this is not PCM RMS.
const float AUDIO_GAIN = 1.0;
const float NOISE_FLOOR = 0.005;
const float MIN_BRIGHTNESS = 0.9; // Minimum peak RGB for theme colours.

float audio_intensity(float value) {
    return clamp((value - NOISE_FLOOR) / (1.0 - NOISE_FLOOR) * AUDIO_GAIN, 0.0, 1.0);
}

float audio_activity() {
    float total = 0.0;
    float peak = 0.0;
    for (int i = 0; i < 64; ++i) {
        float value = audio_intensity(umbriel_audio_spectrum(float(i) / 63.0));
        total += value;
        peak = max(peak, value);
    }
    // A narrow spectral peak should still be visible even with a low mean.
    return max(total / 64.0, 0.25 * peak);
}

vec4 border(vec2 uv) {
    vec4 native = umbriel_sample(uv);
    if (umbriel_audio_available() < 0.5) return native;
    if (native.a <= 0.0) return native;

    float position = (atan(uv.y - 0.5, uv.x - 0.5) + 3.14159265) / 6.2831853;
    float band = audio_intensity(umbriel_audio_spectrum(position));
    float level = audio_activity();
    // Local bands dominate. Ordinary music must leave room for peaks.
    float strength = 0.9 * band + 0.1 * level;
    vec4 tint = umbriel_palette_count > 0
        ? umbriel_palette_at(fract(position + 0.25 * band))
        : vec4(0.25, 0.65, 1.0, 1.0);
    // Dark theme accents can otherwise disappear in the surrounding desktop.
    vec3 colour = tint.rgb;
    float brightness = max(colour.r, max(colour.g, colour.b));
    if (brightness > 0.001) colour *= max(1.0, MIN_BRIGHTNESS / brightness);
    else colour = vec3(MIN_BRIGHTNESS);
    colour = mix(colour, vec3(1.0), 0.16 * band);

    // Keep the native stroke's coverage (already opaque with AA). Recolor
    // RGB so audio still drives the ring without a see-through halo.
    vec3 nativeRgb = native.rgb / native.a;
    vec3 rgb = mix(nativeRgb, colour, strength);
    return vec4(rgb * native.a, native.a);
}
