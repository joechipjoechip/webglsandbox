<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 7, les textures</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import gsap from 'gsap';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

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

				// TEXTURE :
				const imageSource = "/images/door/Door_Wood_001_basecolor.jpg";

				// utilisées uniquement dans l'example 3.5 :
				const imageSourceAlpha = "/images/door/Door_Wood_001_opacity.jpg";
				const imageSourceHeight = "/images/door/Door_Wood_001_height.png";
				const imageSourceNormal = "/images/door/Door_Wood_001_normal.jpg";
				const imageSourceAmbientOcclusion = "/images/door/Door_Wood_001_ambientOcclusion.jpg";
				const imageSourceMetalness = "/images/door/Door_Wood_001_metallic.jpg";
				const imageSourceRoughness = "/images/door/Door_Wood_001_roughness.jpg";

				// 3 manières :

				// 1 : à l'ancienne
				// const image = new Image();
				// let texture = null;
				// image.onload = () => {

				// 	console.log("image is loaded");
				// 	// ici on peut trigger tout ce qui utilise l'image, obviously


				// 	// so :

				// 	// d'abord, on doit transformer l'image en texture
				// 	texture = new THREE.Texture(image);

				// 	console.log("texture : ", texture);

				// 	// problématique pour des raisons de séquencages d'instructions
				// 	// on peut donc faire comme ceci :


				// };

				// image.src = imageSource;

				// - - - - - - - - - - - - - - - - - - - - - - - - - - 
				// 2 : à l'ancienne mais mieux

				// const image = new Image();
				// const texture = new THREE.Texture(image);
				// // oui, même si l'image n'est pas encore chargée, on l'ajoute déjà à la texture

				// image.onload = () => {

				// 	console.log("image is loaded");

				// 	// so :
				// 	texture.needsUpdate = true;
				// 	// on dit "hey, maintenant que l'image est chargée, il faut updater la texture"

				// };

				// image.src = imageSource;

				// - - - - - - - - - - - - - - - - - - - - - - - - - - 

				// 3 : avec un textureloader (mieux, simple, non verbeux, direct)
				// const textureLoader = new THREE.TextureLoader();

				// const texture = textureLoader.load(imageSource);

				// si j'avais n autres textures à loader, inutile d'instancier n fois THREE.TextureLoader()
				// car on peut utiliser n fois la même instance textureLoader, comme ceci par exemple
				// const texture2 = textureLoader(imageSource2);
				// const texture3 = textureLoader(imageSource3);
				// etc..

				// --> 3 callbacks sont possibles dans textureLoader : 
				// const texture = textureLoader.load(
				// 	imageSource,
				// 	() => {
				// 		// loaded
				// 	},
				// 	() => {
				// 		// progress
				// 		// souvent inutile, pas toujours trigger
				// 	},
				// 	() => {
				// 		// error
				// 	}
				// );


				// 3.5 -> Mieux encore : la versoin avec un loadingManager 
				// (qui va mutualiser les events relatifs aux différents loadings (textures/models/fonts/etc))

				const loadingManager = new THREE.LoadingManager();


				loadingManager.onStart = () => {

					console.log("onStart triggered");
					
				};

				loadingManager.onProgress = () => {

					console.log("onProgress triggered");

				};

				loadingManager.onError = () => {

					console.log("onError triggered");

				};

				loadingManager.onLoad = () => {

					console.log("onLoad triggered");

				};

				// bien sur, chacun de ces callback peut avoir un argument qui donne des infos sur son déclenchement
				// (comme l'état du loading etc..)

				// on instancie le loader, qu'on plug directement au loadingManager
				const textureLoader = new THREE.TextureLoader(loadingManager);

				// et ici on comprend mieux pkoi il est utile de garder à l'esprit qu'une seule et même instance de textureLoader suffit :
				// (puisque c'est cette unique instance qui est "linkée" avec le loadingManager)
				const colorTexture = textureLoader.load(imageSource);
				const heightTexture = textureLoader.load(imageSourceHeight);
				const alphaTexture = textureLoader.load(imageSourceAlpha);
				const normalTexture = textureLoader.load(imageSourceNormal);
				const ambientOcclusionTexture = textureLoader.load(imageSourceAmbientOcclusion);
				const MetalnessTexture = textureLoader.load(imageSourceMetalness);
				const RoughnessTexture = textureLoader.load(imageSourceRoughness);


				// ok pour les différentes manières de loader une texture


				// maintenant

				// voyons les "UV"
				// (plan 2d représentant le patron de la texture)

				// colorTexture.repeat.x = 2;

				// à combiner avec :

				// colorTexture.wrapS = THREE.MirroredRepeatWrapping;
				// colorTexture.wrapT = THREE.MirroredRepeatWrapping;

				// et / ou
				// colorTexture.offset.x = 0.1;
				// créer un décalage type offset

				// colorTexture.rotation = Math.PI * 0.25;
				// // va pivoter la texture depuis un point d'origine en bas à gauche (?)

				// // si on veut que le "tranformOrigin" soit au centre de la texture :
				// colorTexture.center.x = 0.5;
				// colorTexture.center.y = 0.5;

				
				// explications sur le "mip mapping" (...)
				// de ce que j'en comprends, mais une lecture approfondie de documentation aiderait :
				// minFilter = minify (si texture trop petite, les pixels seront floutés)
				// colorTexture.minFilter = THREE.NearestFilter;
				// magFilter = magnify (si texture trop petite, les pixels seront laissés tels quels)
				// (?)
				// par default --> LinearFilter
				// donc :
				colorTexture.magFilter = THREE.NearestFilter;
				// aura pour effet d'annuler le blur des trucs étirés

				// NearestFilter améliore les performances

				// le type de filtrage aurait pour but d'éviter les sauts lors d'un passage d'une texture à une autre

				// voilà ce que dit la doc : 
				// .magFilter : number
				// How the texture is sampled when a texel covers more than one pixel. The default is THREE.LinearFilter, which takes the four closest texels and bilinearly interpolates among them. The other option is THREE.NearestFilter, which uses the value of the closest texel.
				// See the texture constants page for details.

				// .minFilter : number
				// How the texture is sampled when a texel covers less than one pixel. The default is THREE.LinearMipmapLinearFilter, which uses mipmapping and a trilinear filter.

				// et aussi ça
				// https://zestedesavoir.com/tutoriels/640/les-cartes-graphiques/516_les-composants-dune-carte-graphique/2537_unites-de-texture/#:~:text=Les%20textures%20sont%20des%20images,papier%20peint%20en%20quelque%20sorte.&text=Pour%20bien%20faire%20la%20diff%C3%A9rence,sont%20couramment%20appel%C3%A9s%20des%20texels.


				// enfin, quand le NearestFilter est utilisé sur le minFilter, le mipmapping devient inutile
				// et peut être désactivé grâce à :
				// colorTexture.generateMipmaps = false;







				// BASE : 

				// Scene
				const scene = new THREE.Scene();

				const geometry = new THREE.BoxGeometry(1,1,1);


				// Material
				const material = new THREE.MeshBasicMaterial({
					map: colorTexture
				});

				// Mesh
				const mesh = new THREE.Mesh(geometry, material);
				scene.add(mesh);










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

				const controls = new OrbitControls(camera, this.$refs.canvas);
				controls.enableDamping = true;

				// Animation
				const tick = () => {

					// sans ce .update() , le damping ne fonctionnera pas ! 
					controls.update();

					renderer.render(scene, camera);

					console.log("requestAnim is triggerd");

					this.animation.run && window.requestAnimationFrame(tick);

				};

				tick();


				// ADD DEBUG GUI
				// params : globalObject, specificKey, min, max, steps
				// gui.add(mesh.position, "x", -3, 3, 0.01);
				// strictement identique à
				// gui.add(mesh.position, "y").min(-3).max(3).step(0.01);

				// donc on peut faire : 
				gui
					.add(mesh.position, "y")
					.min(-3)
					.max(3)
					.step(0.01)
					.name("élévation");

				// maintenant voyons pour un boolean
				// -> mesh.visible
				gui
					.add(mesh, "visible");

				// autre essai boolean
				gui
					.add(material, "wireframe");

				gui
					.add(this.animation, "run")
					.name("run animation");

				// maintenant : les couleurs (voir l'obj parameters, plus haut)
				gui
					.addColor(parameters, "color")
					.onChange(() => {
						// console.log("color has been changed");
						material.color.set(parameters.color);
					});

				gui
					.add(parameters, "spin");
				




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