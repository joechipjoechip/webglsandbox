#define PI 3.14159

// ici on récupère le vUv updaté par le vertex shader
varying vec2 vUv;


// voir https://thebookofshaders.com/10/
float random (vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 rotate(vec2 uv, float rotation, vec2 mid)
{
	return vec2(
	cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
	cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
	);
}

//	Classic Perlin 2D Noise 
//	by Stefan Gustavson
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
	vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
	vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
	Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
	vec4 ix = Pi.xzxz;
	vec4 iy = Pi.yyww;
	vec4 fx = Pf.xzxz;
	vec4 fy = Pf.yyww;
	vec4 i = permute(permute(ix) + iy);
	vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
	vec4 gy = abs(gx) - 0.5;
	vec4 tx = floor(gx + 0.5);
	gx = gx - tx;
	vec2 g00 = vec2(gx.x,gy.x);
	vec2 g10 = vec2(gx.y,gy.y);
	vec2 g01 = vec2(gx.z,gy.z);
	vec2 g11 = vec2(gx.w,gy.w);
	vec4 norm = 1.79284291400159 - 0.85373472095314 * 
		vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
	g00 *= norm.x;
	g01 *= norm.y;
	g10 *= norm.z;
	g11 *= norm.w;
	float n00 = dot(g00, vec2(fx.x, fy.x));
	float n10 = dot(g10, vec2(fx.y, fy.y));
	float n01 = dot(g01, vec2(fx.z, fy.z));
	float n11 = dot(g11, vec2(fx.w, fy.w));
	vec2 fade_xy = fade(Pf.xy);
	vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
	float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
	return 2.3 * n_xy;
}


void main()
{
	// gl_FragColor = vec4(vUv, 0.5, 1.0)

	// pattern 3
	// float strength = vUv.x;

	// pattern 4
	// float strength = vUv.y;

	// pattern 5
	// float strength = 1.0 - vUv.y;

	// pattern 6
	// float strength = vUv.y * 10.0;

	// pattern 7
	// mod = modulo --> mod(valeur, limite)
	// permet de demander à une valeur d'atteindre une limite
	// une fois la limite atteinte, la valeur revient à 0
	// float strength = mod(vUv.y * 10.0, 1.0);

	// pattern 8 (rayures)
	// float strength = mod(vUv.y * 10.0, 1.0);

	// if( strength < 0.5 )
	//     strength = 0.0;
	// else
	//     strength = 1.0;


	// on peut mettre ou ne pas mettres les brackets, peu importe
	// (les ternaires fonctionnent aussi)
	// mais il est très conseillé d'éviter les if/else en glsl
	// parceque ca plombe les perfs, donc on fera plutôt usage du step():
	// step(limit, testedValue)
	// si la testedValue est en dessous de la limit, le retour sera 0
	// si la testedValue est au dessus de la limit, le retour sera 1
	//  ! !
	// strength = step(0.5, strength);

	// pattern 9 (rayures en changeant la limit du step())
	// float strength = mod(vUv.y * 10.0, 1.0);
	// strength = step(0.9, strength);


	// pattern 10 (pareil mais avec vUv.x)
	// float strength = mod(vUv.x * 10.0, 1.0);
	// strength = step(0.9, strength);

	// pattern 11 (quadrillage)
	// float strength = step(0.9, mod(vUv.x * 10.0, 1.0));
	// strength += step(0.9, mod(vUv.y * 10.0, 1.0));

	// pattern 12 (quadrillage avec points)
	// float limit = 0.9;
	// float strength = step(limit, mod(vUv.x * 10.0, 1.0));
	// strength *= step(limit, mod(vUv.y * 10.0, 1.0));

	// pattern 13 (quadrillage avec traits)
	// float strength = step(0.4, mod(vUv.x * 10.0, 1.0));
	// strength *= step(0.8, mod(vUv.y * 10.0, 1.0));

	// pattern 14 (quadrillage avec traits + angles)
	// float barX = step(0.4, mod(vUv.x * 10.0, 1.0));
	// barX *= step(0.8, mod(vUv.y * 10.0, 1.0));

	// float barY = step(0.8, mod(vUv.x * 10.0, 1.0));
	// barY *= step(0.4, mod(vUv.y * 10.0, 1.0));

	// float strength = barX + barY;

	// pattern 15 (quadrillage avec croix)
	// float barX = step(0.4, mod(vUv.x * 10.0, 1.0));
	// barX *= step(0.8, mod(vUv.y * 10.0 + 0.2, 1.0));

	// float barY = step(0.8, mod(vUv.x * 10.0 + 0.2, 1.0));
	// barY *= step(0.4, mod(vUv.y * 10.0, 1.0));

	// float strength = barX + barY;

	// pattern 16 (dégradé noir au centre sur x)
	// float strength = abs(vUv.x - 0.5);

	// pattern 17 (dégradé noir au centre sur x et y)
	// float strength = min(abs(vUv.x - 0.5), abs(vUv.y - 0.5));

	// pattern 18 (dégradé noir au centre sur x et y)
	// float strength = max(abs(vUv.x - 0.5), abs(vUv.y - 0.5));

	// pattern 19 (carré noir sur fond blanc)
	// float strength = max(step(0.2, abs(vUv.x - 0.5)), step(0.2, abs(vUv.y - 0.5)));
	// ou, plus simplement :
	// float strength = step(0.2, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));

	// pattern 20 (carré noir sur fond blanc, plus petit, composé de 2 carrés)
	// float square1 = step(0.2, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));
	// float square2 = 1.0 - step(0.25, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));
	// float strength = square1 * square2;

	// pattern 21 (nuancier de gris)
	// float strength = floor(vUv.x * 10.0) / 10.0;

	// pattern 22 (nuancier de gris en grille)
	// float colX = floor(vUv.x * 10.0) / 10.0;
	// float colY = floor(vUv.y * 10.0) / 10.0;
	// float strength = colX * colY;
	// ou, plus rapidement :
	// float strength = floor(vUv.x * 10.0) / 10.0;
	// strength *= floor(vUv.y * 10.0) / 10.0;

	// pattern 23 (noisy)
	// random n'existe pas en glsl, donc on recréé cette function
	// voir random() au dessus du main()
	// float strength = random(vUv);

	// pattern 24 (noisy mais avec des gros pixels)
	// vec2 gridUv = vec2(
	// 	floor(vUv.x * 10.0) / 10.0,
	// 	floor(vUv.y * 10.0) / 10.0
	// );
	// float strength = random(gridUv);

	// pattern 25 (noisy mais avec des gros pixels , + offset)
	// vec2 gridUv = vec2(
	// 	floor(vUv.x * 10.0) / 10.0,
	// 	floor(vUv.y * 10.0 + vUv.x * 5.0) / 10.0
	// );
	// float strength = random(gridUv);

	// pattern 26 (dégradé radian noir dont le centre est en bas à gauche)
	// float strength = length(vUv);
	// length() retourne la taille du vecteur (?!)
	// https://thebookofshaders.com/glossary/?search=length


	// pattern 27 (dégradé radian noir dont le centre est au centre du carré)
	// float strength = length(vUv - 0.5);
	// ou
	// float strength = distance(vUv, vec2(0.5));
	// distance() retourne la distance entre un vecteur et un point donné
	// distance(vecteurDeBase, pointDonné)
	// https://thebookofshaders.com/glossary/?search=distance

	// ou , pour que le dégradé resté contenu dans le carré (my way) :
	// float strength = length(vUv + (vec2(vUv - 1.0)));


	// pattern 28 (dégradé radian blanc au centre):
	// float strength = 1.0 - distance(vUv, vec2(0.5));

	// pattern 29 (tout petit dégradé radian blanc au centre):
	// float strength = 0.02 / distance(vUv, vec2(0.5));

	// pattern 30 (dégradé étiré radian blanc au centre):
	// ici, les choses deviennent cryptiques pour un non mathématicien
	// même pour le formateur, mais on peut déceler une certaine logique par moments
	// vec2 lightUv = vec2(
	// 	vUv.x * 0.1 + 0.45,
	// 	// 0.45 est un offset, c'est 0.5 moins le coef précédent : 0.1
	// 	vUv.y * 0.5 + 0.25
	// );
	// float strength = 0.02 / distance(lightUv, vec2(0.5));


	// pattern 31 (dégradé étiré sur x et y (comme une croix) radian blanc au centre):
	// ici, les choses deviennent cryptiques pour un non mathématicien
	// même pour le formateur, mais on peut déceler une certaine logique par moments
	// vec2 lightUvX = vec2(vUv.x * 0.1 + 0.45,vUv.y * 0.5 + 0.25);
	// float lightX = 0.02 / distance(lightUvX, vec2(0.5));

	// vec2 lightUvY = vec2(vUv.y * 0.1 + 0.45,vUv.x * 0.5 + 0.25);
	// float lightY = 0.02 / distance(lightUvY, vec2(0.5));

	// float strength = lightX * lightY;



	// pattern 32 : la même chose, mais avec un rotate de 45°
	// on va utiliser rotate() qui est définie en haut avant main()
	// on va également utiliser pi qui est définie plus haut aussi
	// vec2 rotatedUv = rotate(vUv, PI / 4.0, vec2(0.5));

	// vec2 lightUvX = vec2(rotatedUv.x * 0.1 + 0.45,rotatedUv.y * 0.5 + 0.25);
	// float lightX = 0.02 / distance(lightUvX, vec2(0.5));

	// vec2 lightUvY = vec2(rotatedUv.y * 0.1 + 0.45,rotatedUv.x * 0.5 + 0.25);
	// float lightY = 0.02 / distance(lightUvY, vec2(0.5));

	// float strength = lightX * lightY;


	// pattern 33 : cercle noir sur fond blanc
	// float strength = step(0.25, distance(vUv, vec2(0.5)));

	// pattern 34 : espèce de donut dégradé nour sur fond gris dégradé aussi
	// float strength = abs(distance(vUv, vec2(0.5)) - 0.25);

	// pattern 35 : cercle noir fin sur fond blanc
	// float strength = step(0.01, abs(distance(vUv, vec2(0.5)) - 0.25));

	// pattern 36 : cercle blanc fin sur fond noir
	// float strength = 1.0 - step(0.01, abs(distance(vUv, vec2(0.5)) - 0.25));

	// pattern 37 : cercle blanc fin sur fond noir avec ondulations
	// vec2 wavedUv = vec2(
	// 	vUv.x,
	// 	vUv.y + sin(vUv.x * 30.0) * 0.1
	// );
	// float strength = 1.0 - step(0.01, abs(distance(wavedUv, vec2(0.5)) - 0.25));

	// pattern 38 : cercle blanc fin sur fond noir avec ondulations ++ 
	// vec2 wavedUv = vec2(
	// 	vUv.x + sin(vUv.y * 30.0) * 0.1,
	// 	vUv.y + sin(vUv.x * 30.0) * 0.1
	// );
	// float strength = 1.0 - step(0.01, abs(distance(wavedUv, vec2(0.5)) - 0.25));

	// pattern 39 : 
	// vec2 wavedUv = vec2(
	// 	vUv.x + sin(vUv.y * 100.0) * 0.1,
	// 	vUv.y + sin(vUv.x * 100.0) * 0.1
	// );
	// float strength = 1.0 - step(0.01, abs(distance(wavedUv, vec2(0.5)) - 0.25));


	// pattern 40 : angles ! 
	// https://thebookofshaders.com/glossary/?search=atan
	// float angle = atan(vUv.x, vUv.y);
	// float strength = angle;

	// pattern 41 : angles mais en partant du centre
	// float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
	// float strength = angle;

	// pattern 42 : angles en partant du centre + dégradé qui fait le tour complet 
	// float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
	// angle /= PI * 2.0;
	// angle += 0.5;
	// float strength = angle;

	// // pattern 43 : genre de symétrie radiale avec dégradé
	// float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
	// angle /= PI * 2.0;
	// angle += 0.5;
	// angle *= 20.0;
	// angle = mod(angle, 1.0);
	// float strength = angle;

	// pattern 44 : genre de symétrie radiale avec dégradés par leur centres
	// float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
	// angle /= PI * 2.0;
	// angle += 0.5;
	// float strength = sin(angle * 100.0);
	
	// pattern 45 : cercle avec déformations du rayon selone la sinusoid
	// faite dans le pattern précédent
	// float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
	// angle /= PI * 2.0;
	// angle += 0.5;
	// float sinusoid = sin(angle * 100.0);
	// float radius = 0.25 + sinusoid * 0.02;
	// float strength = 1.0 - step(0.01, abs(distance(vUv, vec2(0.5)) - radius));

	// pattern 46 : sorte de surface lunaire floue organique
	// called : perling noise (clouds, smoke, water, fire, terrain elevation)
	// s'apparentent à des algos qui mîment la nature
	// https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
	// attention, certain ne vont pas fonctionner à cause de légères erreurs de positions
	// ici on va utiliser le "classic perlin noise", implémenté plus haut avant le main
	// float strength = cnoise(vUv * 10.0);

	// pattern 47 : perling noise mais contrasté (sans flou)
	// le perling noise qu'on utilise va de -qqch à +qqch
	// donc si on donne une limit de step à 0.0, on obtient déjà ce qu'on cherche
	// float strength = step(0.0, cnoise(vUv * 10.0));

	// pattern 48 : perling noise luminescent
	// float strength = 1.0 - abs(cnoise(vUv * 10.0));

	// pattern 49 : perling noise art nouveau / 70's
	// peut etre sympa à animer avec une uniform de time
	// float strength = sin(cnoise(vUv * 10.0) * 30.0);

	// pattern 50 : pareil que le précédent, mais contrasté, sans dégradé
	// float strength = step(0.8, sin(cnoise(vUv * 10.0) * 30.0));

	// - - - mixed with colors - - -
	// mix(couleur1, couleur2, coef)
	// float variationRatio = sin(cnoise(vUv * 10.0) * 30.0);

	// vec3 blackColor = vec3(0.0);
	// vec3 uvColor = vec3(vUv, 1.0);

	// vec3 strength = mix(blackColor, uvColor, variationRatio);
	// gl_FragColor = vec4(strength, 1.0);

	// maintenant testons ça avec le pattern 11 :
	// float variationRatio= step(0.9, mod(vUv.x * 10.0, 1.0));
	// variationRatio += step(0.9, mod(vUv.y * 10.0, 1.0));

	// vec3 blackColor = vec3(0.0);
	// vec3 uvColor = vec3(vUv, 1.0);

	// vec3 strength = mix(blackColor, uvColor, variationRatio);
	// gl_FragColor = vec4(strength, 1.0);

	// mais on voit qu'aux intersections, on a du blanc, et même parfois un blanc extrapolé
	// donc on peut "recadrer" les valeurs, en disant
	// tu ne vas pas en dessous de 0 et pas au dessus de 1
	// cela se fait avec un clamp()
	// clamp(valeur, min, max)

	float variationRatio= step(0.9, mod(vUv.x * 10.0, 1.0));
	variationRatio += step(0.9, mod(vUv.y * 10.0, 1.0));

	// clamp
	variationRatio = clamp(variationRatio, 0.0, 1.0);

	vec3 blackColor = vec3(0.0);
	vec3 uvColor = vec3(vUv, 1.0);

	vec3 strength = mix(blackColor, uvColor, variationRatio);
	gl_FragColor = vec4(strength, 1.0);



	



	
	





	




	// gl_FragColor = vec4(strength, strength, strength, 1.0);

}