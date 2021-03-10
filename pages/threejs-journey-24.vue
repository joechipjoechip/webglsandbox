<template>
	<div>
		<canvas ref="canvas"></canvas>
	</div>
</template>

<script>

	import * as THREE from 'three';

	// import gsap from 'gsap';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	import vertexShader from "./../components/shaders-homemade/03/vertex.glsl";

	import fragmentShader from "./../components/shaders-homemade/03/fragment.glsl";
import { Uniform } from 'three';

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

				window.addEventListener("resize", (e) => {
					// update values
					sizes = {
						width: window.innerWidth,
						height: window.innerHeight
					};

					// update camera
					for(const camera of this.cameras){
						camera.aspect = sizes.width / sizes.height;
						camera.updateProjectionMatrix();
					}

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

				const getRandom = (min, max) => {
					return Math.random() * (max - min) + min;
				};











				// SETUP
				this.scene = new THREE.Scene();

				// Mesh
				const geometry = new THREE.PlaneBufferGeometry(1,1,128,128);

				const material = new THREE.ShaderMaterial({
					vertexShader,
					fragmentShader,
					side: THREE.DoubleSide,
					uniforms: {
						uBigWavesElevation: { value: 0.2 }
					}
				});

				const plane = new THREE.Mesh(
					geometry,
					material
				);

				plane.rotation.x = Math.PI / 2;

				this.scene.add(plane);


				// Lights
				const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
				this.scene.add(ambientLight);

				const pointLight = new THREE.PointLight(0xffffff, 1, 10, 1);
				pointLight.position.y = 3;
				pointLight.position.x = 3;
				pointLight.position.z = 5;

				this.scene.add(pointLight);


				// Camera
				const aspectRatio = sizes.width / sizes.height;
				const camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				camera.position.z = 1;
				camera.position.y = 1;

				this.scene.add(camera);

				// Axes helper : 
				const axesHelper = new THREE.AxesHelper(2);
				this.scene.add(axesHelper);

				// Renderer
				const renderer = new THREE.WebGLRenderer({
					canvas: this.$refs.canvas
				});

				renderer.setSize(sizes.width, sizes.height);

				renderer.shadowMap.enabled = true;


				// CONTROLS
				const controls = new OrbitControls(camera, this.$refs.canvas);
				controls.enableDamping = true;

				const clock = new THREE.Clock();

				let oldElapsedTime = 0;

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					const deltaTime = elapsedTime - oldElapsedTime;

					oldElapsedTime = elapsedTime;

					// sans ce .update() , le damping ne fonctionnera pas ! 
					controls.update();

					// Do things
					// ...

					// update material dynamic uniform : uTime
					// material.uniforms.uTime.value = elapsedTime;


					// NOW COMPUTE RENDER
					renderer.render(this.scene, camera);

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

	.dg.ac {
		z-index: 10;
	}

	.canvasContainer {

		display: flex;
		flex-direction: row;
		align-items: center;
		justify-content: center;
			
	}

	canvas {
		// position: fixed;
		// top: 0;
		// left: 0;
		// width: 50vw;
		width: 100vw;
		height: 100vw;
		outline: none;
		border: solid 1px green;


		pointer-events: all;
		z-index: 3;
	}


	p {
		color: white;
		z-index: 5;
	}

</style>