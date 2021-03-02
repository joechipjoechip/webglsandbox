// projectionMatrix applique la combinaison des deux suivantes
// dans le clipSpace
// -> fournie par THREE
uniform mat4 projectionMatrix;

// viewMatrix applique les transformations relatives à la caméra 
// ex : camera.position.z = 5
// ex : camera.rotation.x = 1
// -> fournie par THREE
uniform mat4 viewMatrix;

// modelMatrix applique les transformations relatives au Mesh
// ex : monMesh.position.x = 3
// ex : monMesh.rotation.y = 1
// -> fournie par THREE
uniform mat4 modelMatrix;

// cette "position" est la position des vertices du mesh 
// -> fournie par THREE
attribute vec3 position;



// ET MAINTENANT LE CUSTOM :
attribute float aRandom;

varying float vRandom;

void main()
{
	// gl_Position doit être un vec4
	// x, y, z (souvent useless), w (perspective parameter, souvent useless)

	// pour appliquer des matrices, on les multiplie
	// gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);

	// si on décompose cette ligne, ça fait :
	// vec4 modelPosition = modelMatrix * vec4(position, 1.0);
	// vec4 viewPosition = viewMatrix * modelPosition;
	// vec4 projectedPosition = projectionMatrix * viewPosition;

	// maintenant que c'est expliqué, passons aux altérations :

	vec4 modelPosition = modelMatrix * vec4(position, 1.0);
	modelPosition.z += aRandom * 0.5;


	vec4 viewPosition = viewMatrix * modelPosition;


	vec4 projectedPosition = projectionMatrix * viewPosition;


	// enfin, tout le but du vertex shader est forger gl_Position
	gl_Position = projectedPosition;


	// on peut faire notre varying où on veut
	vRandom = aRandom;



}