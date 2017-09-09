
	for (int i = 0; i < 64; ++i) {
        color += pow( texture2D(depthtex4, texCoord.st + hex_offsets[i] * 0.0014598).rgb * 1.0, vec3(2.2));
	}
        color /= 64;
