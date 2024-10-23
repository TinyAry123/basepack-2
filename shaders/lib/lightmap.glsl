vec3 multiplyLightMap(vec3 albedoColor, vec3 lightMapColor) { // Gamma sRGB --> linear sRGB --> ACEScg --> multiply --> linear sRGB --> OkLab output. 
	return SRGB_TO_LINRGB(albedoColor);
}