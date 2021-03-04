<template>
	<div>
		<canvas ref="canvas"></canvas>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import gsap from 'gsap';

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

				// SAND VARIABLES - - - - -
				const nbSubdivisions = 70;
				const SCREENLEVEL = -0.1;
				const ABCARRAY = new Array("a", "b", "c");
				const UNSANDLARGER = nbSubdivisions / 2;
				const UNSANDIMPACT = 0.002;

				// trace
				const largeurTrace = UNSANDLARGER / 12;
				const maxHeight = 0.1;
				const animTrace = true;
				const traceDuration = 0.2;

				let upperFacesPos = [];
				let upperFacesNeg = [];
				// - - - - - - - - - - - - -

				// Particules - - - - - - -
				const particulesCount = 2000;
				// - - - - - - - - - - - - -

				let mouse = new THREE.Vector2();
				let cursor = new THREE.Vector2();
				
				const onDocumentMouseMove = ( event ) => {

					event.preventDefault();
					mouse.x = ( event.clientX / renderer.domElement.clientWidth ) * 2 - 1;
					mouse.y = - ( event.clientY / renderer.domElement.clientHeight ) * 2 + 1;

					cursor.x = event.clientX;
					cursor.y = event.clientY;

					// console.log("mouse : ", mouse);
					// console.log("cursor : ", cursor);

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

				// SANDPLANE
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
					// morphTargets: true,
					// wireframe: true
				});

				const sandGeometry = new THREE.PlaneGeometry(10, 10, nbSubdivisions, nbSubdivisions);

				const sandPlane = new THREE.Mesh(
					sandGeometry,
					sandMaterial
				);



				// SCREEN
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

				// Particules
				const particulesPositions = new Float32Array(particulesCount * 3);
				const particulesColors = new Float32Array(particulesCount * 3);
				const particulesGeometry = new THREE.BufferGeometry(1, 16,16);
				let randomGrey = Math.abs(Math.random() + 0.5);
				const particulesContainerSize = 0.2;

				for(let i = 0; i < particulesCount; i++){

					if( i % 3 === 0 ){
						randomGrey = Math.abs(Math.random() + 0.5);
					}

					particulesPositions[i] = ((Math.random() - 0.5) * 2) * particulesContainerSize;

					particulesColors[i] = randomGrey;

				};

				particulesGeometry.setAttribute(
					'position',
					new THREE.BufferAttribute(particulesPositions, 3)
				);

				particulesGeometry.setAttribute(
					'color',
					new THREE.BufferAttribute(particulesColors, 3)
				);
				// particulesGeometry.color = new THREE.Color("#cec4b4");

				const particuleTexture = textureLoader.load("/images/particules/3.png");

				const particulesMaterial = new THREE.PointsMaterial({
					size: 0.04,
					sizeAttenuation: true,
					alphaMap: particuleTexture,
					transparent: true,
					depthWrite: false,
					// blending: THREE.AdditiveBlending,
					// rien à voir, mais on va donner les randomized colors au matérial :
					vertexColors: true,
					color: 0xcec4b4
				});

				const particules = new THREE.Points(particulesGeometry, particulesMaterial);

				const particulesConfig = {
					size: 0.02,
					ratio: 10
				};
				
				this.scene.add(particules);



				// Lights
				const pointLight1 = new THREE.PointLight(0xffffff, 1, 10, 1);
				pointLight1.position.y = 3;
				pointLight1.position.x = 2;
				this.scene.add(pointLight1);

				const pointLight2 = new THREE.PointLight(0xffffff, 1, 10, 1);
				pointLight2.position.y = 3;
				pointLight2.position.x = -2;
				this.scene.add(pointLight2);


				// RAYCASTER
				const raycaster = new THREE.Raycaster();


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

					if (mouse && mouse.x) {
						
						// RAYCASTER INTERSECTS (terraforming) - - - - - - - - -
						raycaster.setFromCamera( mouse, camera );

						const intersects = raycaster.intersectObjects( [sandPlane, screen] );

						const isHoveringScreen = intersects.filter(intersection => intersection.object.uuid === screen.uuid).length > 0;

						if ( intersects.length > 0 && intersects[0].face ) {

							const center = intersects[0].face.b;

							const currentVertice = sandGeometry.vertices[center];

							const endFace = center + UNSANDLARGER;

							// creuse
							for(let i = center; i < endFace; i++){

								for(const pointKey of ABCARRAY){

									const target = sandGeometry.vertices[intersects[0].face[pointKey]];

									if( target.z >= SCREENLEVEL * 1.1 ){

										target.z -= UNSANDIMPACT;

									}

								}

							}

							// fait une trace autour du creux
							if( !isHoveringScreen ){
								createTrace(center, currentVertice);
							}
							// - - - - - - - - - - - - - - - - - - - - - - - - - 


							// Particules
							for(let i = 0; i < particulesCount; i++){
								
								particulesPositions[i] = (((Math.random() - 0.5) * 2) * particulesContainerSize) + cursor.x;

							};

							particulesGeometry.setAttribute(
								'position',
								new THREE.BufferAttribute(particulesPositions, 3)
							);
							// - - - - - - - - - - - - - - - - - - - - - - - - - 

							

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

				const createTrace = ( center, currentVertice ) => {
					// laisse une trace (rebords plus hauts)
					
					const upperFacesArrays = [upperFacesPos, upperFacesNeg];
					upperFacesPos = [];
					upperFacesNeg = [];

					const currentVerticeAbsZ = Math.abs(currentVertice.z);
					const sandGeometryVertices = sandGeometry.vertices;
					

					for(let i = 1; i < largeurTrace; i++){

						sandGeometryVertices[center + i] && upperFacesPos.push(sandGeometryVertices[center + i]);

						sandGeometryVertices[center - i] && upperFacesNeg.push(sandGeometryVertices[center - i]);

					}

					for( const upperFaceArray of upperFacesArrays ){

						upperFaceArray.forEach((upperFace, index) => {
	
							if( index < 1 ){
								// les premiers font monter moins que les suivants pour arrondir
								// le passage entre creux et trace
	
								if( animTrace ){

									gsap.to(upperFace, {
										duration: traceDuration,
										z: upperFace.z - UNSANDIMPACT / (2 - index)
									});

								} else {

									upperFace.z -= UNSANDIMPACT / (2 - index);

								}

							}
							else if( upperFace.z < maxHeight && upperFace.z > SCREENLEVEL / 2){
								// les suivants, pour créer la trace, vont monter de manière dégressive selon leur éloignement
	
								const elevationRatio = (largeurTrace / (index + 1)) * 0.1;
	

								if( animTrace ){
									
									gsap.to(upperFace, {
										duration: traceDuration,
										z: (currentVerticeAbsZ / 2) + ((UNSANDIMPACT / 2) * elevationRatio)
									});

								} else {

									upperFace.z = (currentVerticeAbsZ / 2) + ((UNSANDIMPACT / 2) * elevationRatio);

								}

							}
							
						});

					}

					// gsap.to(mesh.rotation, {
					// 	duration: 2,
					// 	y: mesh.rotation.y + 10
					// });
					

				};
				

				gui
					.add(this.animation, "run")
					.name("run animation");

			}

		}
	}
</script>

<style lang="scss">

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