precision mediump float;

uniform vec3 uColor;
uniform sampler2D uTexture;

// ici on attrape la varying de position forgée dans le vertex shader
varying vec2 vUv;

// on retrouve notre vElevation
varying float vElevation;

void main()
{
	vec4 textureColor = texture2D(uTexture, vUv);

	textureColor.rgb *= vElevation * 2.0 + 0.9;

	// texture2D() retourne un vec4


	// gl_FragColor = vec4(uColor, 1.0);
	gl_FragColor = textureColor;

}