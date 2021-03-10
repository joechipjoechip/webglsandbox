<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<div class="digCanvasContainer" ref="digCanvas"></div>
		<div class="waveCanvasContainer" ref="waveCanvas"></div>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import * as CANNON from "cannon-es";

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	import vertexShader from "./../components/shaders-homemade/sand/vertex.glsl";

	import fragmentShader from "./../components/shaders-homemade/sand/fragment.glsl";
import { CurvePath } from 'three';

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

				// SCREEN
				const SCREENLEVEL = -0.4;

				// SAND VARIABLES - - - - -
				const sandGrainLifeSpan = 0.5;
				const nbSubdivisions = 120;
				// for canvas
				const DIGCIRCLESIZE = 6;
				// for uniformes
				const DEEPMAX = 0.5;

				let mouse = new THREE.Vector2();
				
				const onDocumentMouseMove = ( event ) => {

					event.preventDefault();
					mouse.x = ( event.clientX / renderer.domElement.clientWidth ) * 2 - 1;
					mouse.y = - ( event.clientY / renderer.domElement.clientHeight ) * 2 + 1;

				};

				const onDocumentMouseLeave = ( event ) => {
					mouse = {};
				};

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

				const getRandom = (min, max) => {
					return Math.random() * (max - min) + min;
				};

				let objectsToUpdate = [];


				const createBalls = (uv, creationTime) => {

					const ballAmount = 10;
					const xTarget = (uv.x * 10) - 5;
					const zTarget = -((uv.y * 10) - 5);

					for(let i = 0; i < ballAmount; i++){

						objectsToUpdate.push(createSphere(0.1, { 
							x: xTarget + getRandom(-0.3, 0.3), 
							y: getRandom(0.1, 0.2), 
							z: zTarget + getRandom(-0.3, 0.3)
						}, creationTime));

					}
					
				};

				const keepFreshBalls = currentTime => {
					const keepedOjects = [];

					for(const object of objectsToUpdate){

						const deltaTime = currentTime - object.birth;

						if( deltaTime > sandGrainLifeSpan ){
							// delete it
							world.removeBody(object.body);
							this.scene.remove(object.mesh);

						} else {
							// keep it
							keepedOjects.push(object);

						}

					}

					objectsToUpdate = keepedOjects;

				}


				const sandGrainGeometry = new THREE.SphereGeometry(0.08, 2,2);
				const sandGrainMaterial = new THREE.MeshStandardMaterial({
					color: 0xffffff,
					metalness: 0,
					roughness: 0.4
				});

				const createSphere = (radius, position, birth) => {

					const mesh = new THREE.Mesh(sandGrainGeometry, sandGrainMaterial);
					const shape = new CANNON.Sphere(radius);

					mesh.scale.set(radius, radius, radius);

					mesh.position.copy(position);

					mesh.castShadow = true;
					mesh.receiveShadow = true;

					this.scene.add(mesh);

					// CANNON
					const body = new CANNON.Body({
						mass: 15,
						position: new CANNON.Vec3(position.x, position.y, position.z),
						shape
					});

					body.position.copy(position);

					world.addBody(body);

					return { mesh, body, birth };

				};

				const generateCannonVertices = (rawVerts) => {
					let verts = [];

					for(let v = 0; v < rawVerts.length; v++){
						verts.push(new CANNON.Vec3(rawVerts[v].x,
							rawVerts[v].y,
							rawVerts[v].z));
					}

					return verts;
				};

				const generateCannonFaces = (rawFaces) => {
					let faces = [];

					for(let f = 0; f < rawFaces.length; f++){
						faces.push([rawFaces[f].a,
							rawFaces[f].b,
							rawFaces[f].c]);
					}

					return faces;
				};

				const updateFloorShape = () => {

					const updatedVerts = generateCannonVertices(sandPlane.geometry.vertices);
					const updatedFaces = generateCannonFaces(sandPlane.geometry.faces);

					const polyhedron = new CANNON.ConvexPolyhedron(updatedVerts,updatedFaces);

					// 

					// body.addShape(polyhedron);
					// console.log("floor body : ", floorBody);

					// floorBody.shapes.updateConvexPolyhedronRepresentation();
					// floorBody.shape.computeBoundingSphereRadius();
					// 
					floorBody.shapes = polyhedron;

					// floorBody.addShape(floorShape);

					// floorBody.computeAABB();
					// world.addBody(floorBody);

				}



				// Canvas invisible qui va récup les position de la souris pour creuser
				this.digCanvas = document.createElement("canvas");
				this.digCtx = this.digCanvas.getContext('2d');
				this.digCanvas.width = 200;
				this.digCanvas.height = 200;
				this.$refs.digCanvas.append(this.digCanvas);
				const canvasDigTexture = new THREE.CanvasTexture(this.digCanvas);
				
				// Canvas invisible qui va récup les position de la souris pour faire des vagues
				this.waveCanvas = document.createElement("canvas");
				this.waveCtx = this.waveCanvas.getContext('2d');
				this.waveCanvas.width = 200;
				this.waveCanvas.height = 200;
				this.$refs.waveCanvas.append(this.waveCanvas);
				const canvasWaveTexture = new THREE.CanvasTexture(this.waveCanvas);






				// SETUP
				this.scene = new THREE.Scene();

				// SANDPLANE
				const textureLoader = new THREE.TextureLoader();
				const sandVersion = "7";
				const sandTextureColor = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_COLOR.jpg`);
				
				const sandMaterial = new THREE.ShaderMaterial({
					vertexShader,
					fragmentShader,
					uniforms: {
						uFrequency: {
							value: new THREE.Vector2(10, 5) 
						},
						uTime: { value: 0 },
						uColor: { value: new THREE.Color("orange") },
						uTexture: { value: sandTextureColor },
						uCanvasDigTexture: { value: canvasDigTexture },
						uCanvasWaveTexture: { value: canvasWaveTexture },
						uDeepMax: { value: DEEPMAX }
					}
				});

				const sandGeometry = new THREE.PlaneGeometry(10, 10, nbSubdivisions, nbSubdivisions);

				const sandPlane = new THREE.Mesh(
					sandGeometry,
					sandMaterial
				);

				sandPlane.rotation.x = Math.PI * -0.5;

				this.scene.add(sandPlane);



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
				
				screen.position.y = SCREENLEVEL;
				screen.rotation.x = Math.PI * -0.5;


				// PHYSICS
				// SETUP CANNON
				const world = new CANNON.World();
				world.broadphase = new CANNON.SAPBroadphase(world);
				world.gravity.set(0, -19.82, 0);

				const defaultMaterial = new CANNON.Material("concrete");

				// Contact Material
				const defaultContactMaterial = new CANNON.ContactMaterial(
					defaultMaterial,
					defaultMaterial,
					{
						// all default values : 0.3
						friction: 0.3,
						restitution: 0.3
					}
				);

				world.addContactMaterial(defaultContactMaterial);
				world.defaultContactMaterial = defaultContactMaterial;

				// Floor
				const floorShape = new CANNON.Plane();
				const floorBody = new CANNON.Body({ type: CANNON.Body.DYNAMIC });
				floorBody.mass = 0;
				// cela ne peut se faire qu'avec un quarternion :
				floorBody.quaternion.setFromAxisAngle(
					// axe :
					new CANNON.Vec3(-1, 0, 0), // <-- ici, l'axe défini est X
					// l'angle
					Math.PI * 0.5
				);

				floorBody.addShape(floorShape);
				world.addBody(floorBody);


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
				camera.position.y = 2;

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
						
						raycaster.setFromCamera( mouse, camera );

						// const intersects = raycaster.intersectObjects( [sandPlane, screen] );
						const intersects = raycaster.intersectObjects( [sandPlane] );

						// const isHoveringScreen = intersects.filter(intersection => intersection.object.uuid === screen.uuid).length > 0;

						const intersectData = intersects.filter(intersect => intersect.object.uuid === sandPlane.uuid)[0];

						// ici on va aller dessiner sur le digCanvas
						if( intersectData ){
							drawOnDigCanvas(intersectData.uv);
							drawOnWaveCanvas(intersectData.uv, elapsedTime);
							canvasDigTexture.needsUpdate = true;
							canvasWaveTexture.needsUpdate = true;

							// physic
							updateFloorShape();
							keepFreshBalls(elapsedTime);
							createBalls(intersectData.uv, elapsedTime);
						}


						// update physics world
						world.step( 1/60, deltaTime, 3);

						// update positions (meshes & bodies)
						for(const object of objectsToUpdate){
							
							// update positions
							object.mesh.position.copy(object.body.position);

							// update angles for bodies
							// object.mesh.quaternion.copy(object.body.quaternion);

						}


					}

					// NOW COMPUTE RENDER
					renderer.render(this.scene, camera);

					console.log("requestAnim is triggerd");

					this.animation.run && window.requestAnimationFrame(tick);

				};

				tick();

				// ce serait cool que le drawOnDigCanvas ne s'applique que quand la souris est en mouvement
				// (pas à l'arret)
				const drawOnDigCanvas = uv => {
					const x = uv.x * this.digCanvas.width;
					const y = (1 - uv.y) * this.digCanvas.height;

					this.digCtx.save();
					this.digCtx.fillStyle = "rgba(255,0,0,0.015)";
					this.digCtx.beginPath();
					this.digCtx.ellipse(x, y, DIGCIRCLESIZE, DIGCIRCLESIZE, 0, 0, 2 * Math.PI);
					this.digCtx.fill();
					// this.digCtx.strokeStyle = "rgba(0,255,0,0.01)";
					// this.digCtx.ellipse(x, y, DIGCIRCLESIZEUP, DIGCIRCLESIZEUP, 0, 0, 2 * Math.PI);
					// this.digCtx.stroke();
					this.digCtx.restore();

				};

				let previousTime = 0;

				const drawOnWaveCanvas = (uv, time) => {
					
					const x = uv.x * this.waveCanvas.width;
					const y = (1 - uv.y) * this.waveCanvas.height;

					const timeDiff = previousTime - time;

					if( timeDiff >= 0.5 ){

						// ici on va chercher à déduire le sens du balayage
						// grace à un différentiel de vecteurs
						// entre le mouse.xy pris à previous time
						// et le mouse.xy pris à time

						// on pourra aussi déduire la vélocité 
						// grâce à l'ampleur de ce différentiel



						previousTime = time;

					}





					// this.waveCtx.save();
					// this.waveCtx.fillStyle = "rgba(0,0,255,0.009)";
					// this.waveCtx.beginPath();
					// this.waveCtx.ellipse(x, y, DIGCIRCLESIZE, DIGCIRCLESIZE, 0, 0, 2 * Math.PI);
					// this.waveCtx.fill();
					// // this.waveCtx.strokeStyle = "rgba(0,255,0,0.01)";
					// // this.waveCtx.ellipse(x, y, DIGCIRCLESIZEUP, DIGCIRCLESIZEUP, 0, 0, 2 * Math.PI);
					// // this.waveCtx.stroke();
					// this.waveCtx.restore();

				};

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

	.webgl {
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

	.digCanvasContainer {
		position: fixed;
		top: 0;
		left: 0;
		border: solid 1px red;
	}

	.waveCanvasContainer {
		position: fixed;
		top: 200px;
		left: 0;
		border: solid 1px blue;
	}


	p {
		color: white;
		z-index: 5;
	}

</style>