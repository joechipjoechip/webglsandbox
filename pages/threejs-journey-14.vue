<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 12, les particules</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	// import gsap from 'gsap';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { Sphere } from 'three';

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
				let mouse = new THREE.Vector2();
				// let mouse = { x: 0, y: 0 }; <-  aurait pu fonctionner

				// Cursor data :
				this.$refs.canvas.addEventListener("mousemove", (e) => {
					cursor = {
						x: e.clientX / sizes.width - 0.5,
						y: e.clientY / sizes.height - 0.5,
					};
				});

				// Cursor data pour le RAYCASTER (mouse):
				this.$refs.canvas.addEventListener("mousemove", (e) => {

					mouse.x = e.clientX / sizes.width * 2 - 1;
					mouse.y = - (e.clientY / sizes.height) * 2 + 1;

				});

				this.$refs.canvas.addEventListener("click", (e) => {

					if( currentIntersect ){
						// clicked on a sphere

						if( currentIntersect.object === sphere){
							// sphere a été cliqué
							console.log("sphere a été cliqué");
						}
						else if( currentIntersect.object === sphere2){
							// sphere a été cliqué
							console.log("sphere2 a été cliqué");
						} else if( currentIntersect.object === sphere3){
							// sphere a été cliqué
							console.log("sphere3 a été cliqué");
						}
					}

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

				// SETUP
				const scene = new THREE.Scene();

				const sphere = new THREE.Mesh(
					new THREE.SphereGeometry(0.5, 8, 8),
					new THREE.MeshBasicMaterial({ 
						color: "red"
					})
				);
				const sphere2 = new THREE.Mesh(
					new THREE.SphereGeometry(0.5, 8, 8),
					new THREE.MeshBasicMaterial({ 
						color: "red"
					})
				);
				const sphere3 = new THREE.Mesh(
					new THREE.SphereGeometry(0.5, 8, 8),
					new THREE.MeshBasicMaterial({ 
						color: "red"
					})
				);

				sphere.position.x = -2;
				sphere3.position.x = 2;

				scene.add(sphere, sphere2, sphere3);


				// RAYCASTER
				// le principe du raycaster c'est d'envoyer un rayon dans une direction, 
				// et de dire si oui ou non ce rayon intersecte avec un élément

				const raycaster = new THREE.Raycaster();

				// la logique :

				// // origin
				// const rayOrigin = new THREE.Vector3(-3, 0, 0);

				// // direction
				// const rayDirection = new THREE.Vector3(10, 0, 0);

				// // pour être sur que la length du ray = 1
				// // il faut toujours normaliser la direction, le raycaster en a besoin
				// rayDirection.normalize();

				// // assemblage des composantes
				// raycaster.set(rayOrigin, rayDirection);


				// // test d'intersection :
				// // 1 : un seul objet :
				// const intersect = raycaster.intersectObject(sphere2);

				// console.log("intersect : ", intersect);

				// // 2 : plusieurs objets
				// const intersects = raycaster.intersectObjects([sphere, sphere2, sphere3]);
				// console.log("intersects : ", intersects);

				// Raycaster depuis la mouse :
				// recréons de toutes pièces les event mouseenter et mouseleave
				// avec une variable "témoin"
				let currentIntersect = null;





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



				const controls = new OrbitControls(camera, this.$refs.canvas);
				controls.enableDamping = true;

				const clock = new THREE.Clock();

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					// sans ce .update() , le damping ne fonctionnera pas ! 
					controls.update();

					// animate spheres
					sphere.position.y = Math.sin(elapsedTime * 0.3) * 1.5;
					sphere2.position.y = Math.sin(elapsedTime * 0.8) * 1.5;
					sphere3.position.y = Math.sin(elapsedTime * 1.4) * 1.5;

					// RAYCASTER 2
					// const rayOrigin = new THREE.Vector3(-3, 0, 0);
					// const rayDirection = new THREE.Vector3(1, 0, 0);
					// rayDirection.normalize();

					// raycaster.set(rayOrigin, rayDirection);

					// const objectsToTest = [sphere, sphere2, sphere3];

					// const intersects = raycaster.intersectObjects(objectsToTest);

					// console.log("raycaster intersects : ", intersects);

					// for(const object of objectsToTest){
					// 	object.material.color.set("#ff0000");
					// }

					// for(const intersect of intersects){

					// 	intersect.object.material.color.set("#0000ff");

					// }

					// RAYCASTER à partir de mouse
					// RAYCASTER à partir de mouse
					// RAYCASTER à partir de mouse
					// RAYCASTER à partir de mouse
					raycaster.setFromCamera(mouse, camera);

					const objectsToTest = [sphere, sphere2, sphere3];

					const intersects = raycaster.intersectObjects(objectsToTest);

					// console.log("raycaster intersects : ", intersects);

					for(const object of objectsToTest){
						object.material.color.set("#ff0000");
					}

					for(const intersect of intersects){

						intersect.object.material.color.set("#0000ff");

					}

					if( intersects.length ){

						if( currentIntersect === null ){
							// mouse enter
							console.log("mouse enter");
						}

						currentIntersect = intersects[0];

					} else {

						if( currentIntersect ){
							// mouse leave
							console.log("mouse leave");

						}

						currentIntersect = null;

					}

					// pour tout ce qui est relatif aux mouseenter/mouseleave/click
					// de bien meilleures implémentations sont évidement possibles
					// là c'est juste ce qui est présenté dans le tuto, pour faire simple



					renderer.render(scene, camera);

					// console.log("requestAnim is triggerd");

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