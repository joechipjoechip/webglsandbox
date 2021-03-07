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

varying float vDigness;

// jordan tips : 
uniform sampler2D uCanvasTexture;




void main()
{
	vec4 modelPosition = modelMatrix * vec4(position, 1.0);

	// float amountRed = texture2D(uCanvasTexture, uv).r;
	// float amountAlpha = texture2D(uCanvasTexture, uv).a;
	float amountToDig = texture2D(uCanvasTexture, uv).r * texture2D(uCanvasTexture, uv).a;
	float amountToUp = texture2D(uCanvasTexture, uv).g * texture2D(uCanvasTexture, uv).a;

	modelPosition.z -= amountToDig;
	modelPosition.z += amountToUp;

	vec4 viewPosition = viewMatrix * modelPosition;
	vec4 projectedPosition = projectionMatrix * viewPosition;

	gl_Position = projectedPosition;


	// ici on update vUv en lui donnant les coordonnées du vertex "en construction"
	vUv = uv;

	vDigness = amountToDig;

}