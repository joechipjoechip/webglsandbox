<template>
	<div>
		<div class="canvasContainer" ref="canvasContainer">

			<canvas ref="canvas1"></canvas>

			<canvas ref="canvas2"></canvas>

		</div>
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

				// core
				this.objectsToUpdate = {
					scene1: [],
					scene2: []
				};

				this.cameras = [];

				// options :
				let sizes = {
					width: window.innerWidth / 2,
					height: window.innerHeight
				};

				let cursor = { x: 0, y: 0 };
				let mouse = new THREE.Vector2();
				// let mouse = { x: 0, y: 0 }; <-  aurait pu fonctionner

				// Cursor data :
				this.$refs.canvas1.addEventListener("mousemove", (e) => {
					cursor = {
						x: e.clientX / sizes.width - 0.5,
						y: e.clientY / sizes.height - 0.5,
					};
				});
				this.$refs.canvas2.addEventListener("mousemove", (e) => {
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

				const parameters = {
					createBalls: () => {

						const ballAmount = 10;

						for(let i = 0; i < ballAmount; i++){

							this.storeAsObjectToUpdate(createSphere("sphere", getRandom(0.05, 0.8), 
								{
									x: getRandom(-3, 3),
									y: getRandom(5, 15),
									z: getRandom(-3, 3)
								})
							);

						}
						
					},
					createBoxes: () => {

						const ballAmount = 10;

						for(let i = 0; i < ballAmount; i++){

							this.storeAsObjectToUpdate(createSphere("box", getRandom(0.05, 0.8), 
								{
									x: getRandom(-3, 3),
									y: getRandom(5, 15),
									z: getRandom(-3, 3)
								})
							);

						}
						
					}
				}

				gui.add(parameters, "createBalls").name("create balls");
				gui.add(parameters, "createBoxes").name("create boxes");

				const getRandom = (min, max) => {
					return Math.random() * (max - min) + min;
				};

				// SETUP
				this.scene1 = new THREE.Scene();
				this.scene2 = new THREE.Scene();

				

				const material = new THREE.MeshStandardMaterial({
					color: 0xffffff,
					metalness: 0,
					roughness: 0.4
				})
				const plane = new THREE.Mesh(
					new THREE.PlaneGeometry(10,10,1),
					material
				);

				plane.rotation.x = Math.PI * -0.5;


				// SETUP CANNON
				this.world1 = new CANNON.World();
				this.world2 = new CANNON.World();

				this.world1.gravity.set(0, -9.82, 0);
				this.world2.gravity.set(0, -9.82, 0);

				// Materials CANNON
				const defaultMaterial = new CANNON.Material("concrete");

				// Contact Material
				const defaultContactMaterial1 = new CANNON.ContactMaterial(
					defaultMaterial,
					defaultMaterial,
					{
						// all default values : 0.3
						friction: 0.1,
						restitution: 0.7
					}
				);
				const defaultContactMaterial2 = new CANNON.ContactMaterial(
					defaultMaterial,
					defaultMaterial,
					{
						// all default values : 0.3
						friction: 0.1,
						restitution: 0.7
					}
				);

				this.world1.addContactMaterial(defaultContactMaterial1);
				this.world1.defaultContactMaterial = defaultContactMaterial1;

				this.world2.addContactMaterial(defaultContactMaterial2);
				this.world2.defaultContactMaterial = defaultContactMaterial2;



			

				// Floor
				const floorShape = new CANNON.Plane();
				const floorBody = new CANNON.Body();

				// mass à 0 indique au moteur physic que c'est un élément qui ne bougera pas
				floorBody.mass = 0;
				// floorBody.material = concreteMaterial; // <-- material way 1
				// floorBody.material = defaultMaterial; // <-- material way 2

				// pour rotate un body, c'est un peu plus complexe dans CANNON
				// cela ne peut se faire qu'avec un quarternion :
				floorBody.quaternion.setFromAxisAngle(
					// axe :
					new CANNON.Vec3(-1, 0, 0), // <-- ici, l'axe défini est X
					// l'angle
					Math.PI * 0.5
				);

				// world.addBody(floorBody);


		

				

				const sphereGeometry = new THREE.SphereGeometry(1, 16, 16);
				const boxGeometry = new THREE.BoxGeometry(1, 1, 1);
				

				const createSphere = (type, radius, position) => {

					let mesh1 = null;
					let mesh2 = null;
					let shape1 = null;
					let shape2 = null;

					// THREE
					switch( type ){

						case "sphere":
							mesh1 = new THREE.Mesh(sphereGeometry, material);
							shape1 = new CANNON.Sphere(radius);

							mesh2 = new THREE.Mesh(sphereGeometry, material);
							shape2 = new CANNON.Sphere(radius);
							break;

						case "box":
							mesh1 = new THREE.Mesh(boxGeometry, material);
							shape1 = new CANNON.Box(new CANNON.Vec3(radius / 2, radius / 2, radius / 2));
							mesh1.rotation.x = Math.PI * 0.25;

							mesh2 = new THREE.Mesh(boxGeometry, material);
							shape2 = new CANNON.Box(new CANNON.Vec3(radius / 2, radius / 2, radius / 2));
							mesh2.rotation.x = Math.PI * 0.25;
							break;

					}
					

					mesh1.scale.set(radius, radius, radius);
					mesh1.position.copy(position);
					mesh1.castShadow = true;
					mesh1.receiveShadow = true;
					
					mesh2.scale.set(radius, radius, radius);
					mesh2.position.copy(position);
					mesh2.castShadow = true;
					mesh2.receiveShadow = true;



					// this.addToScenes(mesh1);
					// this.addToScenes(mesh2);
					this.scene1.add(mesh1);
					this.scene2.add(mesh2);

					// CANNON
					

					const body1 = new CANNON.Body({
						mass: 1,
						position: new CANNON.Vec3(position.x, position.y, position.z),
						shape1
					});
					const body2 = new CANNON.Body({
						mass: 1,
						position: new CANNON.Vec3(position.x, position.y, position.z),
						shape2
					});

					body1.position.copy(position);
					body2.position.copy(position);

					this.world1.addBody(body1);
					this.world2.addBody(body2);

					return { mesh1, mesh2, body1, body2 };

				};

				
				// const count = 20;

				// for(let i = 0; i < count; i++){

				// 	// will create meshes, then add them, then create bodies, the add them
				// 	this.storeAsObjectToUpdate(createSphere("box", getRandom(0.5, 1.5), 
				// 			{
				// 				x: getRandom(-3, 3),
				// 				y: getRandom(0, 10),
				// 				z: getRandom(-3, 3)
				// 			}
				// 		)
				// 	);

				// }

				this.storeAsObjectToUpdate(createSphere("box", 1, 
						{
							x: 0,
							y: 0,
							z: 0
						}
					)
				);








				// Lights
				const hemisphericLight1 = new THREE.HemisphereLight(0xff0000, 0x0000ff, 1);
				const hemisphericLight2 = new THREE.HemisphereLight(0x00ff00, 0x000000, 0.4);
				// this.addToScenes(hemisphericLight);
				this.scene1.add(hemisphericLight1);
				this.scene2.add(hemisphericLight2);

				const pointLight = new THREE.PointLight(0xffffff, 1, 10, 1);
				pointLight.position.y = 3;
				pointLight.position.x = 3;
				this.addToScenes(pointLight);

				// Shadows
				
				plane.receiveShadow = true;
				pointLight.castShadow = true;

				pointLight.shadow.mapSize.width = 1024;
				pointLight.shadow.mapSize.height = 1024;


				// Camera
				const aspectRatio = sizes.width / sizes.height;
				const camera1 = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				const camera1Angle = 0;
				camera1.position.z = 5;
				camera1.position.y = 1;
				camera1.rotation.y = camera1Angle;
				// camera1.rotation.y = Math.PI / 2;

				const camera2 = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				const camera2Angle = 0;
				camera2.position.z = 5;
				camera2.position.y = 1;
				camera2.rotation .y = camera2Angle;
				// camera2.rotation.y = Math.PI / -2;

				const cameraInfos = {
					camera1Angle, camera2Angle
				};

				this.cameras.push(camera1, camera2);

				// then add it to the scene
				// this.addToScenes(camera1);
				this.scene1.add(camera1);
				this.scene2.add(camera2);

				// Axes helper : 
				const axesHelper = new THREE.AxesHelper(2);
				this.addToScenes(axesHelper);

				// Renderer
				const renderer1 = new THREE.WebGLRenderer({
					canvas: this.$refs.canvas1
				});

				const renderer2 = new THREE.WebGLRenderer({
					canvas: this.$refs.canvas2
				});

				renderer1.setSize(sizes.width, sizes.height);
				renderer2.setSize(sizes.width, sizes.height);

				renderer1.shadowMap.enabled = true;
				renderer2.shadowMap.enabled = true;



				// const controls1 = new OrbitControls(camera1, this.$refs.canvasContainer);
				// const controls2 = new OrbitControls(camera2, this.$refs.canvasContainer);
				// controls1.enableDamping = true;
				// controls2.enableDamping = true;
				camera1.lookAt(0,0,0);
				camera2.lookAt(0,0,0);

				const clock = new THREE.Clock();
				let oldElapsedTime = 0;

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					const deltaTime = elapsedTime - oldElapsedTime;

					oldElapsedTime = elapsedTime;

					// sans ce .update() , le damping ne fonctionnera pas ! 
					// controls1.update();
					// controls2.update();


					this.world1.gravity.set(0, Math.cos(elapsedTime), 0);
					this.world2.gravity.set(0, Math.cos(elapsedTime), 0);

					// update des angles de caméras
					// camera1.rotation.y = -1;
					// camera2.rotation.y = Math.PI / -4;
					camera1.rotation.y = cameraInfos.camera1Angle;
					camera2.rotation.y = cameraInfos.camera2Angle;

					// camera1.position.z += Math.cos(elapsedTime) * 0.01;
					// camera2.position.z += Math.cos(elapsedTime) * 0.01;


					// update physics world
					// update physics world
					// this.world1.step( 1/60, deltaTime, 3);
					// this.world2.step( 1/60, deltaTime, 3);

					for(const concernedSceneKey of Object.keys(this.objectsToUpdate)){

						let bodyIndex = 0;
						let bodyKey = null;
						let meshKey = null;

						switch( concernedSceneKey ){
							case "scene1":
								bodyIndex = 1;
								break;

							case "scene2":
								bodyIndex = 2;
								break;
						}

						bodyKey = `body${bodyIndex}`;
						meshKey = `mesh${bodyIndex}`;

						for(const object of this.objectsToUpdate[concernedSceneKey]){

							// debugger;
							
							// update positions
							object[meshKey].position.copy(object[bodyKey].position);
	
							// update angles for bodies
							object[meshKey].quaternion.copy(object[bodyKey].quaternion);
	
						}

					}

					// NOW COMPUTE RENDERS B***
					renderer1.render(this.scene1, camera1);
					renderer2.render(this.scene2, camera2);

					console.log("requestAnim is triggerd");

					this.animation.run && window.requestAnimationFrame(tick);

				};

				tick();
				

				gui
					.add(this.animation, "run")
					.name("run animation");

				gui
					.add(cameraInfos, "camera1Angle")
					.min(Math.PI * -2).max(Math.PI * 2)
					.step(Math.PI / 360)
					.name("cam1 angle");

				gui
					.add(cameraInfos, "camera2Angle")
					.min(Math.PI * -2).max(Math.PI * 2)
					.step(Math.PI / 360)
					.name("cam2 angle");


			},

			addToScenes(element){
				
				const clonedElement2 = element.clone();

				this.scene1.add(element);
				
				this.scene2.add(clonedElement2);

			},

			storeAsObjectToUpdate(element){

				const clonedElement2 = Object.assign({}, element);

				this.objectsToUpdate.scene1.push(element);
				this.objectsToUpdate.scene2.push(clonedElement2);

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
		
		canvas {
			// position: fixed;
			// top: 0;
			// left: 0;
			width: 50vw;
			height: 100vw;
			outline: none;
			border: solid 1px green;


			pointer-events: all;
			z-index: 3;
		}

		
	}


	p {
		color: white;
		z-index: 5;
	}

</style>