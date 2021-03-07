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

	import * as CANNON from "cannon-es";

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
				// this.$refs.canvas.addEventListener("mousemove", (e) => {
				// 	cursor = {
				// 		x: e.clientX / sizes.width - 0.5,
				// 		y: e.clientY / sizes.height - 0.5,
				// 	};
				// });

				// events 

				const SCREENLEVEL = -0.2;
				const UNSANDLARGER = 4;
				const ABCARRAY = new Array("a", "b", "c");
				

				const onDocumentMouseMove = ( event ) => {

					
					event.preventDefault();
					mouse.x = ( event.clientX / renderer.domElement.clientWidth ) * 2 - 1;
					mouse.y = - ( event.clientY / renderer.domElement.clientHeight ) * 2 + 1;

				}

				const onDocumentMouseLeave = ( event ) => {
					mouse = {};
				}

				this.$refs.canvas.addEventListener( 'mousemove', onDocumentMouseMove, false );
				this.$refs.canvas.addEventListener( 'mouseout', onDocumentMouseLeave, false );

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

				const parameters = {};

				const getRandom = (min, max) => {
					return Math.random() * (max - min) + min;
				};

				// SETUP
				this.scene = new THREE.Scene();

				// Textures
				const textureLoader = new THREE.TextureLoader();
				const sandVersion = "7";

				const sandTextureNormal = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_NRM.jpg`);
				const sandTextureColor = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_COLOR.jpg`);
				const sandTextureDisp = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_DISP.png`);
				const sandTextureOcc = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_OCC.jpg`);
				const sandTextureSpec = textureLoader.load(`images/textures/sand1/Sand_001_SPEC.png`);

				const sandMaterial = new THREE.MeshStandardMaterial({
					map: sandTextureColor,
					aoMap: sandTextureOcc,
					normalMap: sandTextureNormal,
					specularMap: sandTextureSpec,
					displacementMap: sandTextureDisp,
					displacementScale: -0.1,
					morphTargets: true,
				});

				

				const sandGeometry = new THREE.PlaneGeometry(10,10,64,64);

				const sandPlane = new THREE.Mesh(
					sandGeometry,
					sandMaterial
				);




				const screenGeometry = new THREE.PlaneGeometry(3,3,1);

				const video = document.createElement("video");
				video.src = "videos/test.mp4";
				video.load();
				video.play();

				const videoTexture = new THREE.VideoTexture(video);
				const screenMaterial = new THREE.MeshBasicMaterial({ 
					map: videoTexture, 
					side: THREE.FrontSide, 
					toneMapped: false 
				});

				const screen = new THREE.Mesh(screenGeometry, screenMaterial);

				this.scene.add(screen);
				this.scene.add(sandPlane);

				sandPlane.rotation.x = Math.PI * -0.5;
				screen.position.y = SCREENLEVEL;
				screen.rotation.x = Math.PI * -0.5;


				// Lights
				// const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
				// this.scene.add(ambientLight);


				const pointLight = new THREE.PointLight(0xffffff, 1, 10, 1);
				pointLight.position.y = 3;
				pointLight.position.x = 3;
				this.scene.add(pointLight);

				// Shadows
				// plane.receiveShadow = true;
				// pointLight.castShadow = true;

				// pointLight.shadow.mapSize.width = 1024;
				// pointLight.shadow.mapSize.height = 1024;

				// RAYCASTER
				const raycaster = new THREE.Raycaster();

				// Raycaster depuis la mouse :
				// recréons de toutes pièces les event mouseenter et mouseleave
				// avec une variable "témoin"
				let currentIntersect = null;


				// Camera
				const aspectRatio = sizes.width / sizes.height;
				const camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				camera.position.z = 5;
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

					// RAYCASTER INTERSECTS (terraforming)
					if (mouse && mouse.x) {

						raycaster.setFromCamera( mouse, camera );

						var intersects = raycaster.intersectObjects( [sandPlane] );

						if ( intersects.length > 0 && intersects[0] && intersects[0].face ) {


							const largerFaces = {
								a: [intersects[0].face.a - UNSANDLARGER, intersects[0].face.a + UNSANDLARGER],
								b: [intersects[0].face.b - UNSANDLARGER, intersects[0].face.b + UNSANDLARGER],
								c: [intersects[0].face.c - UNSANDLARGER, intersects[0].face.c + UNSANDLARGER]
							};

							for(const faceKey of ABCARRAY){

								for(let i = largerFaces[faceKey][0]; i < largerFaces[faceKey][1]; i++){

									if( sandGeometry.vertices[intersects[0].face[faceKey]].z >= SCREENLEVEL * 1.1 ){

										sandGeometry.vertices[intersects[0].face[faceKey]].z -= 0.005;

									}


								}

							};


						}

						mouse = {};

					}

					sandGeometry.verticesNeedUpdate = true;
					sandGeometry.computeFaceNormals();
					sandGeometry.computeVertexNormals();
					



			


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