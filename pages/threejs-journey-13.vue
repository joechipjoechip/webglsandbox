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

				// const parameters = {
				// 	color: 0xff0000,
				// 	spin: () => {
				// 		console.log("spinn triggered");
				// 		gsap.to(mesh.rotation, {
				// 			duration: 2,
				// 			y: mesh.rotation.y + 10
				// 		});
				// 	}
				// };

				const parameters = {};
				parameters.count = 250000;
				parameters.size = 0.01;
				parameters.radius = 4;
				parameters.branches = 3;
				parameters.spin = 3;
				parameters.randomness = 0.2;
				parameters.randomnessPower = 3;
				parameters.insideColor = "#ff3c30";
				parameters.outsideColor = "#1b7184";

				


				// BASE : 
				// Scene
				const scene = new THREE.Scene();

				// GALAXY

				let geometry = null;
				let material = null;
				let points = null;

				
				const generateGalaxy = () => {

					// Destroy old galaxy
					if( points !== null ){

						// .dispose() va libérer la mémoire
						geometry.dispose();

						material.dispose();

						scene.remove(points);

					}

					geometry = new THREE.BufferGeometry({
						vertexColor: true
					});

					const positions = new Float32Array(parameters.count * 3);
					const colors = new Float32Array(parameters.count * 3);

					const colorInside = new THREE.Color(parameters.insideColor);
					const colorOutside = new THREE.Color(parameters.outsideColor);

					for(let i = 0; i < parameters.count; i++){

						const i3 = i * 3;

						// POSITIONS
						const radius = Math.random() * parameters.radius;
						const spinAngle = radius * parameters.spin;
						const branchAngle = ((i % parameters.branches) / parameters.branches) * Math.PI * 2;

						// const randomX = (Math.random() - 0.5) * parameters.randomness;
						// const randomY = (Math.random() - 0.5) * parameters.randomness;
						// const randomZ = (Math.random() - 0.5) * parameters.randomness;
						const randomX = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1);
						const randomY = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1);
						const randomZ = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1);

						// x
						positions[i3] = Math.cos(branchAngle + spinAngle) * radius + randomX;
						// y
						positions[i3 + 1] = 0 + randomY;
						// z
						positions[i3 + 2] = Math.sin(branchAngle + spinAngle) * radius + randomZ;


						// COLORS
						// attention, .lerp() affecte la couleur de base, donc il est indispensable de garder un clone de la valeur de base
						const mixedColor = colorInside.clone();
						mixedColor.lerp(colorOutside, radius / parameters.radius);


						colors[i3 + 0] = mixedColor.r; // r
						colors[i3 + 1] = mixedColor.g; // g
						colors[i3 + 2] = mixedColor.b; // b

					}

					geometry.setAttribute(
						"position",
						new THREE.BufferAttribute(positions, 3)
					);

					geometry.setAttribute(
						"color",
						new THREE.BufferAttribute(colors, 3)
					);

					material = new THREE.PointsMaterial({
						color: "white",
						size: parameters.size,
						depthWrite: false,
						blending: THREE.AdditiveBlending,
						vertexColors: true
					});

					points = new THREE.Points(geometry, material);

					scene.add(points);


				};

				generateGalaxy();

				gui.add(parameters, "count").name("count").min(100).max(600000).step(100).onFinishChange(generateGalaxy);
				gui.add(parameters, "size").name("size").min(0.005).max(0.15).step(0.001).onFinishChange(generateGalaxy);
				gui.add(parameters, "radius").name("radius").min(0.01).max(20).step(0.1).onFinishChange(generateGalaxy);
				gui.add(parameters, "branches").name("branches").min(2).max(20).step(1).onFinishChange(generateGalaxy);
				gui.add(parameters, "spin").name("spin").min(-5).max(5).step(0.1).onFinishChange(generateGalaxy);
				gui.add(parameters, "randomness").name("randomness").min(0).max(2).step(0.01).onFinishChange(generateGalaxy);
				gui.add(parameters, "randomnessPower").name("randomnessPower").min(1).max(10).step(0.01).onFinishChange(generateGalaxy);
				gui.addColor(parameters, "insideColor").name("insideColor").onFinishChange(generateGalaxy);
				gui.addColor(parameters, "outsideColor").name("outsideColor").onFinishChange(generateGalaxy);





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
				// const axesHelper = new THREE.AxesHelper(2);
				// scene.add(axesHelper);

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

					// update du spin :
					points.rotation.y = -0.02 * elapsedTime;



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