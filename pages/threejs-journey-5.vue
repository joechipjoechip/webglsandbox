<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 4, cameras</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	export default {
		mounted(){

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



				// Scene
				const scene = new THREE.Scene();

				// // Positions

				// // const positionsArray = new Float32Array(9);

				// // positionsArray[0] = 0;
				// // positionsArray[1] = 0;
				// // positionsArray[2] = 0;

				// // positionsArray[3] = 0;
				// // positionsArray[4] = 1;
				// // positionsArray[5] = 0;

				// // positionsArray[6] = 1;
				// // positionsArray[7] = 0;
				// // positionsArray[8] = 0;

				// // est strictement équivalent à

				// const positionsArray = new Float32Array([
				// 	0, 0, 0,
				// 	0, 1, 0,
				// 	1, 0, 0
				// ]);

				// // et on continue :
				// const positionsAttribute = new THREE.BufferAttribute(positionsArray, 3);
				// // 3 étant le nombres de coordonnées pour 1 seul vertex

				// const geometry = new THREE.BufferGeometry();
				// geometry.setAttribute("positions", positionsAttribute);


				// // Material
				// const material = new THREE.MeshBasicMaterial({
				// 		color: 0xff0000,
				// 		wireframe: true 
				// });

				// const mesh = new THREE.Mesh(geometry, material);


				// scene.add(mesh);




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
					color: 0xff0000,
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

					// window.requestAnimationFrame(tick);

				};

				tick();

			}
		}
	}
</script>

<style lang="scss" scoped>

	canvas {
		position: fixed;
		top: 0;
		left: 0;
		outline: none;


		pointer-events: all;
		z-index: 3;
	}

	p {
		color: white;
		z-index: 5;
	}

</style>