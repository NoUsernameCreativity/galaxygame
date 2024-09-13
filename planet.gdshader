shader_type spatial;

// uniforms (basically exports). Shown to right are default args.
uniform float grassThreshold = 0.8; 
uniform float sandHeight = 5;
uniform vec3 baseColor = vec3(0, 1, 0);
uniform vec3 slopeColor = vec3(1, 0, 0);
uniform vec3 nearWaterColor = vec3(1, 1, 0);

// varying: these can be passed between vertex and fragment
varying vec3 vertObjectSpace;
varying float surfaceNormalDotSphereNormal;

void vertex() {
	surfaceNormalDotSphereNormal = dot(NORMAL, normalize(VERTEX));
	vertObjectSpace = VERTEX;
}

void fragment() {
	NORMAL = -normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	if(length(vertObjectSpace)<sandHeight){
		ALBEDO = nearWaterColor;
	}
	else{
		if(surfaceNormalDotSphereNormal > grassThreshold){
			ALBEDO = baseColor;
		}
		else{
			ALBEDO = slopeColor;
		}
	}
}