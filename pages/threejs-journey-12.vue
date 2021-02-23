<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 12, les particules</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import gsap from 'gsap';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { Blending, SphereGeometry, SpotLight, VertexColors } from 'three';

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


				// PARTICULES :
				// c'est presque comme créer un mesh, 
				// il faut donc :
				// 1 : une geometry
				// 2 : un material : PointsMaterial
				// 3 : une Points instance qui aura la geometry et le material

				// // Geometry
				// const particulesGeometry = new THREE.SphereBufferGeometry(1, 32, 32);

				// // Material
				// const particulesMaterial = new THREE.PointsMaterial({
				// 	size: 0.02,
				// 	// sizeAttenuation est nécéssaire si l'on veut un effet de perspective sur les particules
				// 	// (éloignées = petites / proches = grosses)
				// 	sizeAttenuation: true
				// });

				// // Points
				// const particules = new THREE.Points(particulesGeometry, particulesMaterial);

				// scene.add(particules);


				// voyons la v2

				// Geometry
				const particulesGeometry = new THREE.BufferGeometry(1, 32, 32);

				// on va créer 500 particules
				const count = 20000;

				// ici on va créer à la main les positions des vertex de notre custom geometry
				// rappel : le *3 vient du fait que chaque vertex va avoir x, y et z
				// rappel : un Float32Array est un array unidimension, qui va stocker des données brutes (ici : de positions)
				const positions = new Float32Array(count * 3);
				// quand on voudra utiliser ce Float32Array, ce sera avec le new THREE.BufferAttribute() 
				// qui aura besoin de l'array mais aussi du "coef de décalage" pour grouper les données correctement (ici : 3)

				for(let i = 0; i < count; i++){

					positions[i] = (Math.random() - 0.5) * 2

				};

				// dans un temps 2, on randomize aussi les couleurs
				// *3 -> r + g + b
				const colors = new Float32Array(count * 3);

				// on aurait pu merger les deux for() , mais on garde ca séparé pour la clareté des notes
				for(let i = 0; i < count; i++){
					
					colors[i] = Math.random();

				};
					

				particulesGeometry.setAttribute(
					'position',
					new THREE.BufferAttribute(positions, 3)
				);

				particulesGeometry.setAttribute(
					'color',
					new THREE.BufferAttribute(colors, 3)
				);

				// Texture de la particule :
				const textureLoader = new THREE.TextureLoader();
				const particuleTexture = textureLoader.load("/images/particules/2.png");

				// Material
				const particulesMaterial = new THREE.PointsMaterial({
					size: 0.02,
					// sizeAttenuation est nécéssaire si l'on veut un effet de perspective sur les particules
					// (éloignées = petites / proches = grosses)
					sizeAttenuation: true,
					// map: particuleTexture,
					alphaMap: particuleTexture,
					transparent: true,
					// dans le cadre des particules, le GPU, même avec alphaMap, va dessiner les pixels supposés invisibles (noirs)
					// il existe plusieurs solution à ce problème :

					// 1 : un réglage supplémentaire : donner un seuil à l'alpha :
					// alphaTest: 0.1,

					// 2 : désactiver les depthTest (dans notre cas, cela fonctionne parfaitement)
					// mais le risque de bugs avec d'autres éléments de la scène est grand
					// les particules seront visibles à travers d'autres éléments, elles ne seront pas cachées
					// depthTest: false

					// 3 : depth write à false -> la meilleure alternative
					depthWrite: false,

					// à savoir que l'impact sur les performances de ces 3 méthodes est dérisoire, elles sont même combinables, selon les besoins

					// 4 : blending (celle-ci a un impact sur les perfs)
					blending: THREE.AdditiveBlending,
					// cette methode va additionner les lights des particules superposées (par rapport au point de vue camera)
					// cela va ajouter de la luminéscence, une sorte de gloomy effect

					// rien à voir, mais on va donner les randomized colors au matérial :
					vertexColors: true,

					// et on peut aussi teinter toutes ces random color, avec une seul et même couleur, en rétablissant : 
					// color: 0xff0000

				});

				// Points
				const particules = new THREE.Points(particulesGeometry, particulesMaterial);
				
				scene.add(particules);



				// on rajoute un éléments pour voir les interaction particule vs elements
				const torus = new THREE.Mesh(
					new THREE.TorusBufferGeometry(0.5, 0.2, 16, 64),
					new THREE.MeshStandardMaterial({ 
						color: 0xffffff,
						metalness: 0.4,
						roughness: 0.4
					})
				);

				scene.add(torus);





				// Lights
				const hemisphericLight = new THREE.HemisphereLight(0xff0000, 0x0000ff, 1);
				scene.add(hemisphericLight);


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


					// update particules : 
					// particules.rotation.y = elapsedTime * 0.1;

					// à ne pas faire, mais on peut tjrs tester :
					// updater le positions (bufferArray)
					for(let i = 0; i < count; i++){


						// // v1 :
						// const i3 = i * 3; 

						// // update the y of each vertex
						// particulesGeometry.attributes.position.array[i3 + 1] = Math.sin(elapsedTime);

						// // on notifie l'update de la geometry à THREE
						// particulesGeometry.attributes.position.needsUpdate = true;


						// // v2 :
						// const i3 = i * 3; 
						// const x = particulesGeometry.attributes.position.array[i3];

						// // update the y of each vertex
						// particulesGeometry.attributes.position.array[i3 + 1] = Math.sin(elapsedTime + x);

						// // on notifie l'update de la geometry à THREE
						// particulesGeometry.attributes.position.needsUpdate = true;


						// mais on ne devrait jamais faire ça comme ça ! (bcp trop gourmand, pas opti du tout)
						// disons que cela peut être utile quand le nombre de particules est léger
						// que ce sont des choses en background d'une scène etc,

						// mais en vrai : on utilisera un custom shader en lieu et place du PointsMaterial
						// et c'est ce custom shader qui appliquera les mouvements

						// on verra ce custom shader, au chapitre dédié aux shaders !

						// so for now, that's all folks !



					}






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