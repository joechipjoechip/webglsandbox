precision mediump float;


// ici je recoit le varying que j'ai créé dans le vertex shader
varying float vRandom;

void main()
{

	gl_FragColor = vec4(vRandom, 0.0, vRandom, 1.0);

}