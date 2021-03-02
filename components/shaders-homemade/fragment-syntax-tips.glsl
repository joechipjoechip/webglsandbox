// va déterminer la précision des float
// le nombre de décimales
// highp / mediump / lowp
// highp peut impacter trop fort les performances, voir ne pas fonctionner sur certaine devices
// lowp peut provoquer des bugs à cause du manque de précision
// donc on utilisera la plupart du temps mediump
precision mediump float;

// - - - - - - - - - - - - - - -
// FUNCTIONS : 
// si ma fonction retourne un float, je dois la déclarer comme tel
// float lorepIpsum()
// {
// 	float a = 2.0;
// 	float b = 3.0;

// 	return a + b;
// }

// et si ma function a besoin de parameters, je dois aussi les typer :
float lorepIpsumParams(float a,float b)
{
	return a + b;
}


void main()
{
	// exemples de syntaxe
	// c'est un language typé, donc chaque type de variable
	// précède sa déclaration

	// les différents types ne se mélangent pas

	// - - - - - - - - - - - - - - -
	// TYPES

	// int a = 2;
	// float b = 1.5;

	// il est possible de convertir à la volée :
	// float c = float(a) + b;

	// - - - - - - - - - - - - - - -
	// VEC2() (x et y)

	// vec2 fonctionne avec des float
	vec2 maPosition = vec2(1.0, 2.5);
	// si on ne donne qu'une valeur à vec2() , allors cette valeur sera utilisée pour x et y

	// par la suite il est possible de réajuster les valeur d'un vec2() :
	maPosition.x = 2.7;

	// enfin, si je multiplie un vec2
	maPosition *= 2.0;

	// alors les deux valeurs sont multipliées par 2

	// - - - - - - - - - - - - - - -
	// VEC3
	// même chose que vec2() mais avec 3 valeurs ( x, y, z )
	// mais peut être utiliser pour stocker une couleur, donc r, g , b
	vec3 purple = vec3(0.0, 1.0, 0.5);
	purple.r = 0.5;
	purple.g = 0.0;
	purple.b = 1.0;
	// les key r/g/b et x/y/z sont mélangeables/interchangeables, ce ne sont que des aliases


	// - - - - - - - - - - - - - - -
	// exemple de manip :
	vec3 foo = vec3(1.0, 2.0, 3.0);
	vec2 bar = foo.xy;
	// ou
	// vec2 bar = foo.zx;

	// on obtient donc dans bar, un bon vec2 avec le x et le y du vec3 bar ;)
	// !!

	// ce genre de manip s'appelle un "swizzle"

	// - - - - - - - - - - - - - - -
	// VEC4
	// même chose que vec2() et vec3() mais avec 4 valeurs ( x, y, z, w ) 
	// (ou r, g, b, a)
	// donc : 
	vec4 truc = vec4(0.5, 1.0, 1.5, 2.5);
	// ou même, avec du swizzle + de la déclaration à la volée :
	vec4 machin = vec4(truc.xw, vec2(0.5, 0.9));




	
	// - - - - - - - - - - - - - - -
	// FUNCTIONS : 
	// même lors de l'appel, je dois aussi déclarer le type :

	// sans parameters : 
	// float monResultat = lorepIpsum();

	// avec parameters :
	float monSuperResultat = lorepIpsumParams(2.5, 6.0);

	// si une fonction ne retourne rien, elle peut être déclarer avec un type : void
	// comme void main(){}



	// - - - - - - - - - - - - - - -
	// NATIVE FUNCTIONS : 
	// cos, sin, max, min, pow, exp, mode, clamp
	// mais aussi :
	// cross, dot, mix, step, smoothstep, lenght, distance, reflect, refract, normalize

	// ressources : 
	// shaderific / kronos group registery (openGL) / book of shaders glossary* (examples tweakables)





	// enfin, tout le but du fragment shader est forger gl_FragColor
	// ici on a un vec4 qui contient r, g, b, a
	gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);

	// (si on veut que l'alpha puisse s'appliquer, ne pas oublier de déclarer transparent: true dans les options du RawShaderMaterial)

}