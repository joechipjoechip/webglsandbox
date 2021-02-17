<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 6, debug ui</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import gsap from 'gsap';

	import * as dat from 'dat.gui';

	console.log("hey dat : ", dat);

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




				// DAT.GUI
				// de base:
				// const gui = new dat.GUI();
				// mais aussi
				const gui = new dat.GUI({
					closed: true,
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





				// Scene
				const scene = new THREE.Scene();


				// mais reprenons tout ça, écrivons le autrement : 
				const count = 50;
				const geometry = new THREE.BufferGeometry();

				const positionsArray = new Float32Array(count * 3 * 3);
				// * 3 (coordonnées xyz) / * 3 (il faut 3points pour un triangle)

				for(let i = 0; i < count * 3 * 3; i++){
					positionsArray[i] = (Math.random() - 0.5 ) * 3;
				}

				const positionsAttribute = new THREE.BufferAttribute(positionsArray, 3);
				geometry.setAttribute("position", positionsAttribute);

				// Material
				const material = new THREE.MeshBasicMaterial({
					color: parameters.color,
					wireframe: true 
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

				this.animation.run && tick();


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