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

				// Group :
				const group = new THREE.Group();
				group.position.y = -1;
				group.scale.y = 2;

				// fast way to create a mesh
				const cube1 = new THREE.Mesh(
					new THREE.BoxGeometry(1,1,1),
					new THREE.MeshBasicMaterial({ color: 0xff0000 })
				);

				const cube2 = new THREE.Mesh(
					new THREE.BoxGeometry(1,1,1),
					new THREE.MeshBasicMaterial({ color: 0x00ff00 })
				);
				cube2.position.x = 2;

				const cube3 = new THREE.Mesh(
					new THREE.BoxGeometry(1,1,1),
					new THREE.MeshBasicMaterial({ color: 0x0000ff })
				);
				cube3.position.x = -2;

				group.add(cube1);
				group.add(cube2);
				group.add(cube3);

				scene.add(group);


				// then add it to the scene
				// scene.add(mesh);
				scene.add(group);


				// Camera
				const aspectRatio = sizes.width / sizes.height;
				console.log("espaect ratio : ", aspectRatio);

				const camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				// const camera = new THREE.OrthographicCamera(
				// 	-1 * aspectRatio, 
				// 	1 * aspectRatio, 
				// 	1, 
				// 	- 1, 
				// 	0.1, 100
				// );
				camera.position.z = 3;

				// camera.lookAt(mesh.position);
				// camera.lookAt(group.position);

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

					// basic : 
					// camera.position.set(
					// 	cursor.x * 10, 
					// 	- cursor.y * 10, 
					// 	camera.position.z
					// );

					// trigonometric trick
					// camera.position.set(
					// 	Math.sin(cursor.x * Math.PI * 2) * 3, 
					// 	- cursor.y * 5, 
					// 	Math.cos(cursor.x * Math.PI * 2) * 3
					// );

					// camera.lookAt(group.position);

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