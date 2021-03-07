precision mediump float;

uniform vec3 uColor;
uniform sampler2D uTexture;

// ici on attrape la varying de position forgée dans le vertex shader
varying vec2 vUv;

// on retrouve notre vDigness
varying float vDigness;

void main()
{
	vec4 textureColor = texture2D(uTexture, vUv);

	textureColor.rgb -= (vDigness / 2.0);

	gl_FragColor = vec4(textureColor.rgb, 1.0);

}