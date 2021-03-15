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
	float digRed = texture2D(uCanvasDigTexture, uv).r;
	float digAlpha = texture2D(uCanvasDigTexture, uv).a;
	float currentDignessImpact = digRed * digAlpha;

	float waveBlue = texture2D(uCanvasWaveTexture, uv).b;
	float waveAlpha = texture2D(uCanvasWaveTexture, uv).a;
	float currentWaveImpact = waveBlue * waveAlpha;


	float amountToDig = min(currentDignessImpact, uDeepMax);
	float amountToWave = currentWaveImpact * 0.15;

	modelPosition.y -= amountToDig;

	modelPosition.y += amountToWave;

	vec4 viewPosition = viewMatrix * modelPosition;
	vec4 projectedPosition = projectionMatrix * viewPosition;

	gl_Position = projectedPosition;


	// ici on update vUv en lui donnant les coordonnées du vertex "en construction"
	vUv = uv;

	vDigness = currentDignessImpact;

}