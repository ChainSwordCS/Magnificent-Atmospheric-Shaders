float nearDist = 2.0 * near;
float nearToFar = far - near;
float farToNear = far + near;

float getLinearDepth(in float depth) {
	return nearDist / (farToNear - depth * nearToFar);
}