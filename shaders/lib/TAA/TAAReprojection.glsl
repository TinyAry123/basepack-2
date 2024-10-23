uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse, gbufferPreviousModelView, gbufferPreviousProjection;
uniform vec3 cameraPosition, previousCameraPosition;

vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homogeneousPosition = projectionMatrix * vec4(position, 1.0);

	return homogeneousPosition.xyz / homogeneousPosition.w;
}

void TAAReprojection(out vec3 reprojectedScreenPosition, vec3 screenPosition, vec2 bufferSize) {
	vec3 ndcPosition = screenPosition * 2.0 - 1.0;

	vec3 viewPosition = projectAndDivide(gbufferProjectionInverse, ndcPosition);

	vec3 feetPlayerPosition = (gbufferModelViewInverse * vec4(viewPosition, 1.0)).xyz;

	vec3 worldPosition = feetPlayerPosition + float(screenPosition.z > 0.56) * cameraPosition;

	// To previous camera

	vec3 previousFeetPlayerPosition = worldPosition - float(screenPosition.z > 0.56) * previousCameraPosition;

	vec3 previousViewPosition = (gbufferPreviousModelView * vec4(previousFeetPlayerPosition, 1.0)).xyz;

	vec3 previousNDCPosition = projectAndDivide(gbufferPreviousProjection, previousViewPosition);

	vec3 previousScreenPosition = previousNDCPosition * 0.5 + 0.5;

	reprojectedScreenPosition = previousScreenPosition;
}