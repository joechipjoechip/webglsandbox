<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 16, la physic (factorisée</p>
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

				const parameters = {
					createBalls: () => {

						const ballAmount = 10;

						for(let i = 0; i < ballAmount; i++){

							objectsToUpdate.push(createSphere("sphere", getRandom(0.05, 0.8), 
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

							objectsToUpdate.push(createSphere("box", getRandom(0.05, 0.8), 
								{
									x: getRandom(-3, 3),
									y: getRandom(5, 15),
									z: getRandom(-3, 3)
								})
							);

						}
						
					},
					reset: () => {

						for(const object of objectsToUpdate){

							// remove body
							object.body.removeEventListener("collide", playHitSound);
							world.removeBody(object.body);

							// remove mesh
							scene.remove(object.mesh);

						}

					}
				}

				gui.add(parameters, "createBalls").name("create balls");
				gui.add(parameters, "createBoxes").name("create boxes");
				gui.add(parameters, "reset").name("reset");

				const getRandom = (min, max) => {
					return Math.random() * (max - min) + min;
				};

				// SOUND
				const hitSound = new Audio("/sounds/hit.mp3");

				const playHitSound = (collision) => {

					// récupérer la puissance de la collision :
					const impactStrength = collision.contact.getImpactVelocityAlongNormal();

					if( impactStrength > 1.5 ){

						// bien sur dans l'ideal, on regle le volume en fonction du impactStrength,
						// mais bref

						hitSound.currentTime = 0;
						hitSound.play();

					}
					

				};

				// SETUP
				const scene = new THREE.Scene();
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

				// scene.add(plane);

				// SETUP CANNON
				// CANNON n'a pas été update depuis des années,
				// mais des gens l'ont forké et l'ont amélioré :
				// npm install --save cannon-es@0.15.1

				// En terme d'opti :
				// ne pas oublier que la physic est généralement traité dans un thread différent du CPU
				// grâce aux workers
				const world = new CANNON.World();

				// manière opti de calculer les collisions
				world.broadphase = new CANNON.SAPBroadphase(world);

				// autre opti : permet de dire qu'un body qui ne bouge plus ne doit pas être testé
				// et don't worry, si un autre body vient le toucher, alors il se reveillera et sera testé à nouveau
				world.allowSleep = true;

				// on peut aussi régler, si on veut :
				// sleepSpeedLimit et sleepTimeLimit
				// pour affiner les statuts de sleeping et wakeup
				// mais ici on va faire confiance aux valeurs par default, qui sont plus très bien calibrées

				world.gravity.set(0, -9.82, 0);
				// -9.82 est la gravité terrestre

				// Materials : 1 way (harder but more explicative)
				// const concreteMaterial = new CANNON.Material("concrete");
				// // la string passée en arg n'est qu'une référence, pour pouvoir discriminer les Cannon matérials plus tard
				// const plasticMaterial = new CANNON.Material("plastic");

				// // Contact Material
				// const concretePlasticContactMaterial = new CANNON.ContactMaterial(
				// 	concreteMaterial,
				// 	plasticMaterial,
				// 	{
				// 		// all default values : 0.3
				// 		friction: 0.1,
				// 		restitution: 0.7
				// 	}
				// );

				// world.addContactMaterial(concretePlasticContactMaterial);

				// Materials : 2nd way (simplier)
				const defaultMaterial = new CANNON.Material("concrete");

				// Contact Material
				const defaultContactMaterial = new CANNON.ContactMaterial(
					defaultMaterial,
					defaultMaterial,
					{
						// all default values : 0.3
						friction: 0.1,
						restitution: 0.7
					}
				);

				world.addContactMaterial(defaultContactMaterial);

				// material v3 :
				// grâce à cette instruction, plus besoin de passer les materials aux bodys
				// tous les éléments déclarés dans le world seront soumis aux propriétés de defaultContactMaterial
				world.defaultContactMaterial = defaultContactMaterial;



				// Sphere
				// Body() is a body played with physic
				// un body a besoin d'une shape
				// const sphereShape = new CANNON.Sphere(0.5);

				// const sphereBody = new CANNON.Body({
				// 	mass: 1,
				// 	position: new CANNON.Vec3(0, 3, 0),
				// 	shape: sphereShape,

				// 	// une fois que le contact material a été créé, on l'ajoute ici :
				// 	// material: plasticMaterial // <-- material way 1
				// 	// material: defaultMaterial // <-- material way 2
				// });

				// world.addBody(sphereBody);

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


				// il est tout à fait possible d'ajouter plusieurs shapes à un seul body, pour faire des models complexes
				// mais ici on en a qu'un
				// floorBody.addShape(floorShape);

				world.addBody(floorBody);

				// ok, la balle tombe et rebondi, on est bien,

				// maintenant : 

				// APPLY FORCES
				// APPLY FORCES
				// APPLY FORCES
				// applyForce() créé comme un vent, une force constante d'une intensité spécifiée, qui a une source et une direction
				// fait évoluer la vélocité si l'objet n'est pas freiné
				// applyImpulse créé une impulsion, qui aura pour effet de faire évoluer la vélocité de l'objet ciblé
				// applyLocalForce() = applyForce mais le 0,0,0 correspond au centre de l'objet (pas de la scène)
				// applyLocalImpulse() = applyImpulse mais le 0,0,0 correspond au centre de l'objet (pas de la scène)

				




				

				const sphereGeometry = new THREE.SphereGeometry(1, 16, 16);
				const boxGeometry = new THREE.BoxGeometry(1, 1, 1);
				

				const createSphere = (type, radius, position) => {

					let mesh = null;
					let shape = null;

					// THREE
					switch( type ){

						case "sphere":
							mesh = new THREE.Mesh(sphereGeometry, material);
							shape = new CANNON.Sphere(radius);
							break;

						case "box":
							mesh = new THREE.Mesh(boxGeometry, material);
							shape = new CANNON.Box(new CANNON.Vec3(radius / 2, radius / 2, radius / 2));
							mesh.rotation.x = Math.PI * 0.25;
							break;

					}
					

					mesh.scale.set(radius, radius, radius);

					mesh.position.copy(position);

					mesh.castShadow = true;
					mesh.receiveShadow = true;

					scene.add(mesh);

					// CANNON
					

					const body = new CANNON.Body({
						mass: 1,
						position: new CANNON.Vec3(position.x, position.y, position.z),
						shape
					});

					body.position.copy(position);

					body.addEventListener("collide", playHitSound);


					// Enfin, il est possible de créer des contraintes physiques avec : 
					// HingeConstraint (exemple : une porte)
					// DistanceConstraint (exemple : des aimants qui se répulsent)
					// LockConstraint (exemple : deux bodys attachés)
					// PointToPointConstraint (exemple: deux bodys attachés par un point précis)

					// --> pour ça et d'autres points de la doc : 
					// https://schteppe.github.io/cannon.js/

					world.addBody(body);

					return { mesh, body };

				};

				const objectsToUpdate = [];
				const count = 20;

				for(let i = 0; i < count; i++){

					// will create meshes, then add them, then create bodies, the add them
					objectsToUpdate.push(createSphere("box", getRandom(0.5, 1.5), 
							{
								x: getRandom(-3, 3),
								y: getRandom(0, 10),
								z: getRandom(-3, 3)
							}
						)
					);

				}








				// Lights
				const hemisphericLight = new THREE.HemisphereLight(0xff0000, 0x0000ff, 1);
				scene.add(hemisphericLight);

				const pointLight = new THREE.PointLight(0xffffff, 1, 10, 1);
				pointLight.position.y = 3;
				pointLight.position.x = 3;
				scene.add(pointLight);

				// Shadows
				
				plane.receiveShadow = true;
				pointLight.castShadow = true;

				pointLight.shadow.mapSize.width = 1024;
				pointLight.shadow.mapSize.height = 1024;


				// Camera
				const aspectRatio = sizes.width / sizes.height;
				const camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				camera.position.z = 3;
				camera.position.y = 0.5;

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

				renderer.shadowMap.enabled = true;



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


					world.gravity.set(0, Math.cos(elapsedTime), 0);


					// update physics world
					// update physics world
					world.step( 1/60, deltaTime, 3);

					// update positions (meshes & bodies)
					for(const object of objectsToUpdate){
						
						// update positions
						object.mesh.position.copy(object.body.position);

						// update angles for bodies
						object.mesh.quaternion.copy(object.body.quaternion);

					}



					

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