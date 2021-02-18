<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 10, les lights</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import gsap from 'gsap';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	import { RectAreaLightHelper } from 'three/examples/jsm/helpers/RectAreaLightHelper.js';

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

				const sphere = new THREE.Mesh(
					new THREE.SphereGeometry(0.5, 32, 32),
					material
				);

				const cube = new THREE.Mesh(
					new THREE.BoxGeometry(1,1,1),
					material
				);
				
				const torus = new THREE.Mesh(
					new THREE.TorusBufferGeometry(0.5, 0.2, 16, 64),
					material
				);
				

				const plane = new THREE.Mesh(
					new THREE.PlaneGeometry(10, 10, 1),
					material
				);

				// leurs positions
				sphere.position.x = -1.5;
				torus.position.x = 1.5;

				plane.position.y = -0.7;
				plane.rotation.x = Math.PI * -0.5;

				scene.add(sphere, cube, torus, plane);


				// LES LIGHTS
				// const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
				// est équivalent à
				// const ambientLight = new THREE.AmbientLight();
				// ambientLight.color = new THREE.Color(0xffffff);
				// ambientLight.intensity = 0.1;
				// scene.add(ambientLight);

				// directional light
				// est "comme le soleil": tous ses rayons sont parallèles

				// const directionalLight = new THREE.DirectionalLight(0x0000ff, 0.5);
				// directionalLight.position.set(1, 0.25, 0);
				// scene.add(directionalLight);

				// une directionalLight visera toujours le centre de la scène,
				// c'est donc sa position qui influera sur l'orientation de ses rayons
				// et : utilisée sans notion de shadows, la directionalLight éclaire tjrs à la même intensité
				// peu importe qu'elle soit proche ou éloignée des objets, les rayons arrivent tjrs avec la même intensité

				// HemisphereLight :
				// le 1er parametre vient du haut, le 2eme param vient du bas
				// const hemisphereLight = new THREE.HemisphereLight(0xff0000, 0x0000ff, 0.3);
				// scene.add(hemisphereLight);


				// pointing light
				// params : couleur, intensité, [portée, decay]
				// portée étant la portée (default : 0 (qui signifie : aucune limite de portée))
				// décay étant le facteur de décroissance de l'intensité de la light (par defaut : 1)
				// const pointLight = new THREE.PointLight(0x00ffff, 0.5, 4, 2);
				// pointLight.position.set(1, 0.5, 1);
				// scene.add(pointLight);

				// rectAreaLight
				// assimilable au projecteur+diffuseur de lumières utilisés pour des shootings photo
				// sa position est donc importante
				// attention ! c'est une light qui ne fonctionne qu'avec MeshStandardMaterial et MeshPhysicalMaterial
				// const rectAreaLight = new THREE.RectAreaLight(0x00ffff, 2, 3, 2);
				// const rectAreaLightHelper = new RectAreaLightHelper(rectAreaLight);
				// rectAreaLight.add(rectAreaLightHelper);
				// rectAreaLight.position.z = 3;
				// rectAreaLight.position.x = -1;
				// rectAreaLight.position.y = 0.5;

				// rectAreaLight.lookAt(new THREE.Vector3);
				// // new THREE.Vector3 tel quel produira 0,0,0, ce qui correspond au centre de la scene
				// // donc utiliser new THREE.Vector3 tel quel revient à viser le centre de la scene
				// scene.add(rectAreaLight);

				// spotlight : 
				// params : couleur, intensité, distance, angle, pénombre, decay
				// penombre : correspond au flous autour du rayon lumineux
				// -> pénombre à 0 : on aura une lumière ultra tranchée
				// -> pénombre à 1 : on aura une diffusion aux contours de la light
				// decay : encore : facteur de décroissance de l'intensité de la light
				const spotlight = new THREE.SpotLight(0xff0000, 0.5, 10, Math.PI * 0.1, 1, 1);
				spotlight.position.z = 3;

				// spotlight.lookAt(torus.attributes.uv);
				// ne fonctionnera pas (on sait pas pkoi)

				// il faudra donc faire comme suit :
				spotlight.target.position.set(
					torus.position.x,
					torus.position.y,
					torus.position.z
				);
				scene.add(spotlight);
				scene.add(spotlight.target);



				// ok, maintenant, gardons à l'esprit que les lights sont gourmandes

				// Les moins gourmandes sont :
				// AmbientLight
				// HemisphereLight

				// Les normales sont :
				// DirectionalLight
				// PointLight

				// Les plus gourmandes : 
				// Spotlight
				// RectAreaLight


				// il existe des techniques pour éviter d'avoir trop de lights dans une scene
				// tout en gardant un rendu sympa
				// c'est valable dans des cas précis :
				// comme : une abscence de mouvement des lights et une absence de mouvement des objets (seule la camera est abilité à bouger, par exemple)
				// alors : le BAKING prend tout son sens
				// le Baking : c'est le fait de précalculer les lights sur les textures dans un logiciel de 3d
				// d'exporter les textures avec les lights appliquées dessus
				// et de se servir de ces textures dans Threejs
				// on fait ainsi l'économie des lights sur la scène
				// (une simple ambient light suffira à tout révéler)























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




				const clock = new THREE.Clock();

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					// sans ce .update() , le damping ne fonctionnera pas ! 
					controls.update();



					// update des meshs
					sphere.rotation.y = 0.1 * elapsedTime;
					cube.rotation.y = 0.1 * elapsedTime;
					torus.rotation.y = 0.1 * elapsedTime;
					sphere.rotation.x = 0.1 * elapsedTime;
					cube.rotation.x = 0.1 * elapsedTime;
					torus.rotation.x = 0.1 * elapsedTime;

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