// raging sea

uniform float uBigWavesElevation;

// ici on déclare une varying, qu'on va update dans le main()
varying vec2 vUv;

void main()
{
	vec4 modelPosition = modelMatrix * vec4(position, 1.0);

	float elevation = sin(modelPosition.x) * uBigWavesElevation

	modelPosition.y += elevation;





	vec4 viewPosition = viewMatrix * modelPosition;
	vec4 projectedPosition = projectionMatrix * viewPosition;


	gl_Position = projectedPosition;

	vUv = uv;
}