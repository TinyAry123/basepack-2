#ifndef SAMPLER_TEXELFETCH_CLAMPED
	#define SAMPLER_TEXELFETCH_CLAMPED true

	#define texelFetch(tex, xy, lod)               texelFetch(tex, clamp(xy, ivec2(0, 0), textureSize(tex, 0) - 1), lod)
	#define texelFetchOffset(tex, xy, lod, offset) texelFetch(tex, xy + offset, lod)
#endif

#ifdef TAA
	void SMAANeighborhoodBlending(out vec3 color, out float depth, sampler2D colorTex, sampler2D depthTex, sampler2D blendTex, vec2 uv, vec2 bufferSize) { // Anti-alias depth as well for TAA. 
		ivec2 texelCoord = ivec2(uv * bufferSize);

		vec4 a = vec4(texelFetchOffset(blendTex, texelCoord, 0, ivec2( 1,  0)).w, texelFetchOffset(blendTex, texelCoord, 0, ivec2( 0,  1)).y, texelFetch(blendTex, texelCoord, 0).zx);

		if (a.x + a.y + a.z + a.w >= 0.0000001) {
			uv += max(a.x, a.z) > max(a.y, a.w) ? vec2(mix(a.x, -a.z, a.z / (a.x + a.z)) / bufferSize.x, 0.0) : vec2(0.0, mix(a.y, -a.w, a.w / (a.y + a.w)) / bufferSize.y);

			color = catmullRomTexture2D(colorTex, uv).rgb;
			depth = catmullRomTexture2D(depthTex, uv).r;
		
			return;
		}

		color = texelFetch(colorTex, texelCoord, 0).rgb;
		depth = texelFetch(depthTex, texelCoord, 0).r;
	}
#else
	void SMAANeighborhoodBlending(out vec3 color, sampler2D colorTex, sampler2D blendTex, vec2 uv, vec2 bufferSize) {
		ivec2 texelCoord = ivec2(uv * bufferSize);

		vec4 a = vec4(texelFetchOffset(blendTex, texelCoord, 0, ivec2( 1,  0)).w, texelFetchOffset(blendTex, texelCoord, 0, ivec2( 0,  1)).y, texelFetch(blendTex, texelCoord, 0).zx);

		if (a.x + a.y + a.z + a.w >= 0.0000001) {
			uv += max(a.x, a.z) > max(a.y, a.w) ? vec2(mix(a.x, -a.z, a.z / (a.x + a.z)) / bufferSize.x, 0.0) : vec2(0.0, mix(a.y, -a.w, a.w / (a.y + a.w)) / bufferSize.y);

			color = catmullRomTexture2D(colorTex, uv).rgb;
		
			return;
		}

		color = texelFetch(colorTex, texelCoord, 0).rgb;
	}
#endif