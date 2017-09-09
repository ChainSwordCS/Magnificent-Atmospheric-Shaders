	if (isEyeInWater > 0){
	for (int i = 0; i < 64; ++i) {
        color += pow( texture2D(colortex0, texCoord.st + hex_offsets[i] * 0.0164598).rgb * 1.0, vec3(2.2));
	}
        color /= 64;

        }