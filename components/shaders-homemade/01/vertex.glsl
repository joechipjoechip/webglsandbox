uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;

uniform vec2 uFrequency;
uniform float uTime;

attribute vec3 position;

// ET MAINTENANT LE CUSTOM :
attribute float aRandom;

// ici on accède à la position du vertex actuellement "en construction"
attribute vec2 uv;

// et ici on créé une varying pour pouvoir y stocker un vec2,
// pour pouvoir la transmettre au frag shader
varying vec2 vUv;

varying float vElevation;



void main()
{
	vec4 modelPosition = modelMatrix * vec4(position, 1.0);

	float elevation = sin(modelPosition.x * uFrequency.x - uTime) * 0.1;
	elevation += sin(modelPosition.y * uFrequency.y - (uTime / 2.0)) * 0.1;

	// équivalent à :
	// modelPosition.z += sin(modelPosition.x * uFrequency.x - uTime) * 0.1;
	// modelPosition.z += sin(modelPosition.y * uFrequency.y - (uTime / 2.0)) * 0.1;
	// mais ça nous a permis de stocker les valeur dans "elevation"
	// qui va etre passée au fragment shader

	modelPosition.z += elevation;

	vec4 viewPosition = viewMatrix * modelPosition;
	vec4 projectedPosition = projectionMatrix * viewPosition;

	gl_Position = projectedPosition;


	// ici on update vUv en lui donnant les coordonnées du vertex "en construction"
	vUv = uv;

	// update de la float vElevation
	vElevation = elevation;

}