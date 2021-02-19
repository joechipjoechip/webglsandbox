<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 11, les shadows</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import gsap from 'gsap';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { SphereGeometry, SpotLight } from 'three';

	export default {
		mounted(){

			this.animation = {
				run: true
			};

			this.init();

		},

		methods: {

			init(){

				// options :
				let sizes = {
					width: window.innerWidth,
					height: window.innerHeight
				};

				let cursor = { x: 0, y: 0 };

				// Cursor data :
				this.$refs.canvas.addEventListener("mousemove", (e) => {
					cursor = {
						x: e.clientX / sizes.width - 0.5,
						y: e.clientY / sizes.height - 0.5,
					};
				});

				window.addEventListener("resize", (e) => {
					// update values
					sizes = {
						width: window.innerWidth,
						height: window.innerHeight
					};

					// update camera
					camera.aspect = sizes.width / sizes.height;
					camera.updateProjectionMatrix();

					// update renderer
					renderer.setSize(sizes.width, sizes.height);

					// renderer.setPixelRatio(window.devicePixelRatio);
					// on limite le pixelratio à 2 pour garder de la perf
					renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

				});

				window.addEventListener("dblclick", (e) => {

					const fullscreenElement = document.fullscreenElement || document.webkitFullscreenElement;
					// webkit --> safari

					if( !fullscreenElement ){

						// go fullscreen

						if( this.$refs.canvas.requestFullscreen ){

							this.$refs.canvas.requestFullscreen();

						}
						else if( this.$refs.canvas.webkitRequestFullscreen ){

							this.$refs.canvas.webkitRequestFullscreen()

						}

					} 
					else {
						// leave fullscreen

						if( document.exitFullscreen ){

							document.exitFullscreen();

						}
						else if( document.webkitExitFullscreen ){

							document.webkitExitFullscreen();

						}

					}

				});

				const gui = new dat.GUI({
					closed: false,
					width: 400
				});

				// gui.hide();
				// le gui sera caché de base, pour l'afficher il faudra taper "h"

				const parameters = {
					color: 0xff0000,
					spin: () => {
						console.log("spinn triggered");
						gsap.to(mesh.rotation, {
							duration: 2,
							y: mesh.rotation.y + 10
						});
					}
				};


				// BASE : 
				// Scene
				const scene = new THREE.Scene();


				// les differents mesh :
				const material = new THREE.MeshStandardMaterial();
				material.roughness = 0.4;
				material.metalness = 0.4;
				
				const torus = new THREE.Mesh(
					new THREE.TorusBufferGeometry(0.5, 0.2, 16, 64),
					material
				);
				torus.castShadow = true;
				
				const plane = new THREE.Mesh(
					new THREE.PlaneGeometry(10, 10, 1),
					material
				);
				plane.receiveShadow = true;

				// leurs positions
				plane.position.y = -0.7;
				plane.rotation.x = Math.PI * -0.5;

				scene.add(torus, plane);

				// LIGHTS
				const ambientLight = new THREE.AmbientLight(0xffffff, 0.2);
				scene.add(ambientLight);

				const directionalLight = new THREE.DirectionalLight(0xffffff, 0.2);
				directionalLight.position.set(2, 2, -1);
				directionalLight.castShadow = true;

				scene.add(directionalLight);


				// SHADOWS

				// d'abord, il faut donner au renderer l'instruction de jouer le jeu des shadows avec :
				// renderer.shadowMap.enabled = true;

				// ensuite, il faut distinguer :
				// - les objets qui provoqueront une ombre portée -> monMesh.castShadow = true
				// - les objets qui recevront les ombres portées provoquées par d'autres objets -> monMeshQuiRecoit.receiveShadow = true
				// - les lights qui vont être appliquées au mesh emeteurs et recepteurs de shadows -> maLight.castShadow = true

				// voici les SEULS types de lights qui supportent les shadows : 
				// PointLight / DirectionalLight / SpotLight

				// Le résultat est là, ok, mais il peut/doit être optimisé :


				// OPTIMISATIONS
				// OPTIMISATIONS
				// OPTIMISATIONS
				// principe : les lights qui supportent les shadows sont munies d'une camera qui leur est propre 
				// qui leur permet de maper les shadows depuis leur point de vue propre

				// 1 : resize la mapSize des shadows de la light
				directionalLight.shadow.mapSize.width = 1024;
				directionalLight.shadow.mapSize.height = 1024;
				// pour ne pas entraver le mipmapping, gardons toujours des tailles qui sont des multiples de 2
				// 512 (default) / 1024 / 2048 / etc ..

				// voir explications ci-après
				directionalLight.shadow.camera.near = 1;
				directionalLight.shadow.camera.far = 6;

				// specific à la directional camera
				// rappel : c'est une camera orthographic ( = qui ne tient pas compte de la perspective )
				// tous les rayons sont paralèles, peut importe la distance de l'objet, c'est partout la même intensité lumineuse
				directionalLight.shadow.camera.top = 2;
				directionalLight.shadow.camera.right = 2;
				directionalLight.shadow.camera.bottom = -2;
				directionalLight.shadow.camera.left = -2;

				// 2 : recalibrer le near et far de la camera de la light
				// (mais aussi l'amplitude* -> left / right / top / bottom)
				// pour la soulager des calculs inutiles
				// pour ce faire, utilisons un camera helper
				const directionalLightHelper = new THREE.CameraHelper(directionalLight.shadow.camera);
				// scene.add(directionalLightHelper);
				// grâce à ce helper on peut voir que le near est convenable, mais que le far est bcp trop grand
				// donc on peut modifier cette valeur afin d'avoir une range de calculs convenable :
				// directionalLight.shadow.camera.far = 6;
				// en revanche, si on veut pouvoir visualiser cette update de valeur, il faut que celle-ci soit déclarée avant le helper
				// voir ci-dessus donc.

				// * enfin, une autre opti de la camera des shadows, consiste à recalibrer son amplitude :
				// directionalLight.shadow.camera.top = 2;
				// directionalLight.shadow.camera.bottom = 2;
				// etc
				// sachant que ces coordonnées se basent sur le centre de la camera
				// 2 pour top et -2 pour bottom équivaut donc à dire que la hauteur de la camera sera de 4
				// pareil pour left et right
				// (avec la même subtilité : si je veux pouvoir constater, il faut que ce soit déclaré avant le helper)

				// enfin, quand on a plus besoin du helper mais qu'on veut le garder au cas où pour plus tard :
				directionalLightHelper.visible = false;

				// on peut aussi appliquer un blur aux shadows pour un meilleur rendu :
				directionalLight.shadow.radius = 5;


				// Continuons :

				// il existe différents algos pour le calcul des shadows
				// celui par défaut est : THREE.PCFShadowMap
				// mais il en existe d'autres, avec des pro/cons différents impactant sur les performances et les rendus
				// celui que nous allons tester est : THREE.PCFSoftShadowMap
				// en revanche, le radius (blur) ne fonctionnera pas avec ce type de rendu de shadow
				// cette déclaration se fera sur le renderer, voir plus bas donc.


				// maintenant, voyons avec une spotLight
				// SPOTLIGHT
				// SPOTLIGHT
				const spotlight = new THREE.SpotLight(0xffffff, 0.2, 10, Math.PI * 0.3);
				spotlight.castShadow = true;
				spotlight.position.set(0,2,2);
				scene.add(spotlight);
				scene.add(spotlight.target);

				// on a accès donc, aux même types d'optis : 
				spotlight.shadow.mapSize.width = 1024;
				spotlight.shadow.mapSize.height = 1024;
				spotlight.shadow.camera.near = 2;
				spotlight.shadow.camera.far = 6;

				// en revanche, dans le cadre d'une light spotlight,
				// le top/bottom/left/right n'est plus valable puisqu'il s'agit d'une lumière qui gère la perspective
				// contrairement à la directionalLight qui est orthographic (tous les rayons sont parallèles et de même intensité que l'on soit loin ou proche)
				// donc pour le spotlight, on utilisera le fov (field of view) qui correspond à l'angle de vue de la camera (en degrés)
				spotlight.shadow.camera.fov = 30;

				const spotlightCameraHelper = new THREE.CameraHelper(spotlight.shadow.camera);
				scene.add(spotlightCameraHelper);
				spotlightCameraHelper.visible = false;


				// maintenant, voyons avec une pointlight
				// POINTLIGHT
				// POINTLIGHT
				// rappel : la pointlight emet de la lumière dans toutes les directions

				const pointlight = new THREE.PointLight(0xffffff, 0.5);
				pointlight.castShadow = true;
				pointlight.position.set(-1, 1, 0);
				scene.add(pointlight);

				// donc on peut opti la base :
				pointlight.shadow.mapSize.width = 1024;
				pointlight.shadow.mapSize.height = 1024;
				pointlight.shadow.camera.near = 0.1;
				pointlight.shadow.camera.far = 6;
				// mais 
				// ni top/bottom/right/left puisque la pointlight éclaire dans tous les sens
				// ni le fov , pour la même raison


				// et le helper APRES pour constater :
				const pointlightCameraHelper = new THREE.CameraHelper(pointlight.shadow.camera);
				scene.add(pointlightCameraHelper);
				pointlightCameraHelper.visible = false;

				// OK !


				// BAKING
				// BAKING
				// BAKING
				// maintenant parlons du "baking"
				// rappel : plaquer les lumières et ombres sur les textures directement
				// pour avoir des lights/shadows précalculées, et ainsi soulager le renderer d'une montagne de calculs
				// pour ce faire, afin d'éviter de devoir modifier toutes les déclarations éparses relatives aux shadows
				// on peut aller directement soulager le renderer avec renderer.shadowMap.enabled = false;

				// donc étape 1 : aller fabriquer sa texture dans un logiciel de 3d type blender
				//  [...]

				// étape 2 : charger sa texture
				const textureLoader = new THREE.TextureLoader();
				const bakedShadowTexture = textureLoader.load("/images/shadows/bakedShadow.jpg");
				console.log(bakedShadowTexture);


				// - - - pour les besoins de l'exemple et pour pas tout casser :
				torus.visible = false;
				plane.visible = false;
				const sphereGeometry = new THREE.SphereGeometry(0.5, 32, 32);
				const sphere = new THREE.Mesh(
					sphereGeometry,
					material
				);
				// - - - -

				// étape 3 : utiliser MeshBasicMaterial (à la place de MeshStandardMaterial);
				const bakedPlane = new THREE.Mesh(
					new THREE.PlaneBufferGeometry(10,10,1),
					new THREE.MeshBasicMaterial({ map: bakedShadowTexture })
				);
				bakedPlane.position.y = -0.7;
				bakedPlane.rotation.x = Math.PI * -0.5;

				// attention, quand on utilise THREE.Mesh() les déclarations ne semblent pas dynamiques ..
				// (on doit tout instancier à l'interieur directement, comme ci-dessus)

				scene.add(sphere, bakedPlane);


				// OK POUR LE BAKING STATIC


				// Maintenant, voyons le Baking Dynamique
				// principe : 
				// on appliquer une texture baked sur le plane,
				// mais on va correler son opacité avec la proximité de la sphere
				// et sa position avec la position de la sphere
				//  . . .

				// donc pour pas tout casser :
				bakedPlane.visible = false;
				plane.visible = true;

				// donc go :
				const simpleShadowTexture = textureLoader.load("/images/shadows/simpleShadow.jpg");

				const simpleShadowPlane = new THREE.Mesh(
					new THREE.PlaneBufferGeometry(1.5, 1.5),
					new THREE.MeshBasicMaterial({
						color: 0x000000,
						transparent: true,
						alphaMap: simpleShadowTexture
					})
				);
				simpleShadowPlane.rotation.x = Math.PI * -0.5;
				simpleShadowPlane.position.y = plane.position.y + 0.001;

				scene.add(simpleShadowPlane);
























				// Camera
				const aspectRatio = sizes.width / sizes.height;
				const camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				camera.position.z = 3;

				// then add it to the scene
				scene.add(camera);






				// Axes helper : 
				const axesHelper = new THREE.AxesHelper(2);
				scene.add(axesHelper);

				// Renderer
				const renderer = new THREE.WebGLRenderer({
					canvas: this.$refs.canvas
				});

				renderer.setSize(sizes.width, sizes.height);

				// renderer.shadowMap.enabled = true;
				renderer.shadowMap.enabled = false;

				renderer.shadowMap.type = THREE.PCFSoftShadowMap;












				const controls = new OrbitControls(camera, this.$refs.canvas);
				controls.enableDamping = true;

				const clock = new THREE.Clock();

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					// sans ce .update() , le damping ne fonctionnera pas ! 
					controls.update();



					// update des meshs
					if( torus.visible ){
						torus.rotation.y = 0.1 * elapsedTime;
						torus.rotation.x = 0.1 * elapsedTime;
					}



					// updates pour le dynamic baking
					// faire bouger la sphere
					sphere.position.set(
						Math.cos(elapsedTime) * 1.5,
						Math.abs(Math.sin(elapsedTime * 3)),
						Math.sin(elapsedTime) * 1.5,
					);
					// update la simpleShadow
					simpleShadowPlane.position.set(
						sphere.position.x,
						simpleShadowPlane.position.y,
						sphere.position.z
					);
					simpleShadowPlane.material.opacity = (1 - sphere.position.y) * 0.4;






					renderer.render(scene, camera);

					console.log("requestAnim is triggerd");

					this.animation.run && window.requestAnimationFrame(tick);

				};

				tick();
				

				gui
					.add(this.animation, "run")
					.name("run animation");


			}
		}
	}
</script>

<style lang="scss" scoped>

	canvas {
		// position: fixed;
		// top: 0;
		// left: 0;
		outline: none;


		pointer-events: all;
		z-index: 3;
	}

	p {
		color: white;
		z-index: 5;
	}

</style>