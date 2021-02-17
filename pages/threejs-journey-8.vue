<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 8, les materials</p>
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


				// TEXTURES :
				// textureLoader : 
				const loadingManager = new THREE.LoadingManager();
				const textureLoader = new THREE.TextureLoader(loadingManager);

				loadingManager.onStart = (url, itemsLoaded, itemsTotal) => {
					console.log("onStart triggered, e = ", url, itemsLoaded, itemsTotal);
				};
				loadingManager.onError = (e) => {
					console.log("onError triggered, e = ", e);
				};
				loadingManager.onProgress = (url, itemsLoaded, itemsTotal) => {
					console.log("onProgress triggered, e = ", url, itemsLoaded, itemsTotal);
				};
				loadingManager.onLoad = () => {
					console.log("onLoad triggered ! ");
				};

				


				const path = "/images/exomaterials/textures";
				

				const doorNormal = textureLoader.load(path + "/door/normal.jpg");
				const doorColor = textureLoader.load(path + "/door/color.jpg");
				const doorAlpha = textureLoader.load(path + "/door/alpha.jpg");
				const doorHeight = textureLoader.load(path + "/door/height.jpg");
				const doorRoughness = textureLoader.load(path + "/door/roughness.jpg");
				const doorMetalness = textureLoader.load(path + "/door/metalness.jpg");

				const gradient = textureLoader.load(path + "/gradients/3.jpg");

				const matcap = textureLoader.load(path + "/matcaps/4.png");

				// BASE : 
				// Scene
				const scene = new THREE.Scene();


				// Material
				// 1 :
				// const material = new THREE.MeshBasicMaterial();
				// material.map = doorColor;
				// material.color.set("purple");

				// material.opacity = 0.5;
				// ne fonctionnera pas sans
				// material.transparent = true;

				// material.alphaMap = doorAlpha;
				// ne fonctionnera pas sans
				// material.transparent = true;

				// material.side = THREE.DoubleSide;
				// pour voir la texture depuis l'interieur d'un objet tronqué également

				// 2 : 
				// const material = new THREE.MeshNormalMaterial();
				// voir les faces
				// material.flatShading = true


				// 3: 
				// const material = new THREE.MeshMatcapMaterial();
				// material.matcap = matcap;
				// material.side = THREE.DoubleSide;
				// material.flatShading = true;

				// 4 : 
				// const material = new THREE.MeshDepthMaterial();
				// material dont le principe est : ce qui est proche du near de la camera est blanc,
				// ce qui est proche du far de la camera est black


				// 5 : 
				// pour celui là on a besoin de lights
				const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
				const pointLight = new THREE.PointLight(0xffffff, 0.5);
				pointLight.position.set(2, 3, 4);

				// const material = new THREE.MeshLambertMaterial();

				// const material = new THREE.MeshPhongMaterial();
				// material.shininess = 250;
				// material.specular = new THREE.Color("red");



				// const material = new THREE.MeshToonMaterial();
				// gradient.minFilter = THREE.NearestFilter;
				// gradient.magFilter = THREE.NearestFilter;
				// gradient.generateMipmaps = false;
				// material.gradientMap = gradient;

				// 47min : Mesh Standard Material












				const sphere = new THREE.Mesh(
					new THREE.SphereGeometry(0.5, 16, 16),
					material
				);
				sphere.position.x = -1.5;

				const plane = new THREE.Mesh(
					new THREE.PlaneGeometry(1, 1),
					material
				);

				const torus = new THREE.Mesh(
					new THREE.TorusGeometry(0.3, 0.2, 16, 32),
					material
				);
				torus.position.x = 1.5;

				scene.add(sphere, plane, torus, ambientLight, pointLight);














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
					plane.rotation.y = 0.1 * elapsedTime;
					torus.rotation.y = 0.1 * elapsedTime;

					sphere.rotation.x = 0.15 * elapsedTime;
					plane.rotation.x = 0.15 * elapsedTime;
					torus.rotation.x = 0.15 * elapsedTime;

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
				// gui
				// 	.add(mesh.position, "y")
				// 	.min(-3)
				// 	.max(3)
				// 	.step(0.01)
				// 	.name("élévation");

				// // maintenant voyons pour un boolean
				// // -> mesh.visible
				// gui
				// 	.add(mesh, "visible");

				// // autre essai boolean
				// gui
				// 	.add(material, "wireframe");

				gui
					.add(this.animation, "run")
					.name("run animation");

				// maintenant : les couleurs (voir l'obj parameters, plus haut)
				// gui
				// 	.addColor(parameters, "color")
				// 	.onChange(() => {
				// 		// console.log("color has been changed");
				// 		material.color.set(parameters.color);
				// 	});

				// gui
				// 	.add(parameters, "spin");
				




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