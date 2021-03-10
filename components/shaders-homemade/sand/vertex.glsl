uniform vec2 uFrequency;
uniform float uTime;
uniform float uDeepMax;

// et ici on créé une varying pour pouvoir y stocker un vec2,
// pour pouvoir la transmettre au frag shader
varying vec2 vUv;

varying float vDigness;

uniform sampler2D uCanvasDigTexture;
uniform sampler2D uCanvasWaveTexture;




void main()
{
	vec4 modelPosition = modelMatrix * vec4(position, 1.0);
	float currentRedOnCanvas = texture2D(uCanvasDigTexture, uv).r;
	float currentAlphaOnCanvas = texture2D(uCanvasDigTexture, uv).a;
	float currentDignessImpact = currentRedOnCanvas * currentAlphaOnCanvas;

	float amountToDig = min(currentDignessImpact, uDeepMax);

	modelPosition.y -= amountToDig;

	vec4 viewPosition = viewMatrix * modelPosition;
	vec4 projectedPosition = projectionMatrix * viewPosition;

	gl_Position = projectedPosition;


	// ici on update vUv en lui donnant les coordonnées du vertex "en construction"
	vUv = uv;

	vDigness = currentDignessImpact;

}