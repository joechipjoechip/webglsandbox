<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 27, post processing</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js"

	import { EffectComposer } from "three/examples/jsm/postprocessing/EffectComposer.js";

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

				const debugObject = {};

				const gltfLoader = new GLTFLoader();
				// si on a compressé le model à l'export dans blender, on aura besoin d'un DRACOLoader



				// BASE : 
				// Scene
				const scene = new THREE.Scene();

				// update all materials (to environmentMap on)
				const updateAllMAterials = () => {

					scene.traverse(child => {

						if( child instanceof THREE.Mesh && child.material instanceof THREE.MeshStandardMaterial ){

							// child.material.envMap = environmentMap;
							// useless now parcequ'on a utilisé un moyen plus simple plus bas : 
							// --> scene.environment = environmentMap;


							child.material.envMapIntensity = debugObject.envMapIntensity;

							child.material.needsUpdate = true;

							child.castShadow = true;
							child.receiveShadow = true;

						}

					});

				};

				// test sphere
				// const testSphere = new THREE.Mesh(
				// 	new THREE.SphereBufferGeometry(1,32,32),
				// 	new THREE.MeshStandardMaterial()
				// );

				// scene.add(testSphere);

				const envMapPath = "/environmentMaps/2";
				const cubeTextureLoader = new THREE.CubeTextureLoader();
				const environmentMap = cubeTextureLoader.load([
					`${envMapPath}/px.jpg`,
					`${envMapPath}/nx.jpg`,
					`${envMapPath}/py.jpg`,
					`${envMapPath}/ny.jpg`,
					`${envMapPath}/pz.jpg`,
					`${envMapPath}/nz.jpg`
				]);

				environmentMap.encoding = THREE.sRGBEncoding;

				// mettre l'environmentMap en fond de la scene :
				scene.background = environmentMap;
				scene.environment = environmentMap;

				debugObject.envMapIntensity = 5;
				gui.add(debugObject, "envMapIntensity").min(0).max(10).step(0.001).onChange(updateAllMAterials);


				// MODEL
				gltfLoader.load(
					"/models/flightHelmet/glTF/FlightHelmet.gltf",
					(gltf) => {
						// console.log("succeed");
						// console.log(gltf);

						// ne pas confondre la "scene" de THREE avec la "scene" d'un model importé
						// le scene d'un model est un group qui est un ensemble des éléments qui constituent le model

						gltf.scene.scale.set(10,10,10);
						gltf.scene.position.set(0, -4, 0);
						// gltf.scene.rotation.y = Math.PI * 0.5;

						gui.add(gltf.scene.rotation, "y").min(- Math.PI).max(Math.PI).step(0.001).name("rotation");

						scene.add(gltf.scene);

						updateAllMAterials();
					}
				);
				// gltfLoader.load(
				// 	"/models/hishamburger.glb",
				// 	(gltf) => {
				// 		// console.log("succeed");
				// 		// console.log(gltf);

				// 		// ne pas confondre la "scene" de THREE avec la "scene" d'un model importé
				// 		// le scene d'un model est un group qui est un ensemble des éléments qui constituent le model

				// 		gltf.scene.scale.set(0.1, 0.1, 0.1);
				// 		gltf.scene.position.set(0, 0, 0);
				// 		// gltf.scene.rotation.y = Math.PI * 0.5;

				// 		gui.add(gltf.scene.rotation, "y").min(- Math.PI).max(Math.PI).step(0.001).name("rotation");

				// 		scene.add(gltf.scene);

				// 		updateAllMAterials();
				// 	}
				// );

				// Lights
				const directionalLight = new THREE.DirectionalLight(0xFFFFFF, 3);
				directionalLight.position.set(3.2, 3, 2.35);

				directionalLight.castShadow = true;
				directionalLight.shadow.camera.far = 15;
				directionalLight.shadow.mapSize.set(1024, 1024);

				// pour éviter les artefact d'ombres sur les models importés : 
				directionalLight.shadow.normalBias = 0.02;

				scene.add(directionalLight);

				// const directionalLightHelper = new THREE.CameraHelper(directionalLight.shadow.camera);
				// scene.add(directionalLightHelper);

				gui.add(directionalLight, "intensity").min(0).max(10).step(0.001).name("intensity");
				gui.add(directionalLight.position, "x").min(-5).max(5).step(0.001).name("light x");
				gui.add(directionalLight.position, "y").min(-5).max(5).step(0.001).name("light y");
				gui.add(directionalLight.position, "z").min(-5).max(5).step(0.001).name("light z");


				// Camera
				const aspectRatio = sizes.width / sizes.height;
				const camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				camera.position.z = 5;

				// then add it to the scene
				scene.add(camera);






				// Axes helper : 
				const axesHelper = new THREE.AxesHelper(2);
				scene.add(axesHelper);

				// Renderer
				const renderer = new THREE.WebGLRenderer({
					canvas: this.$refs.canvas,

					// ne peut pas être déclaré en dehors de l'instanciation
					antialias: true
				});

				renderer.setSize(sizes.width, sizes.height);

				// NEW ! --> set lights physically realistic
				// très utile pour récupérer les lights de blender par exemple
				renderer.physicallyCorrectLights = true;

				// indispensable pour avoir le rendu realist
				renderer.outputEncoding = THREE.sRGBEncoding;

				// le tone mapping est un algo qui permet de passer dur HDR au LDR
				// même si on utilise pas de texture HDR, le rendu sera amélioré si on fait un toneMapping
				// plusieurs algo sont disponibles : LinearToneMapping / ReinhardToneMapping / CineonToneMapping
				// un des plus cool est : ACESFilmicToneMapping
				// mais pour l'exo on va utiliser Reinhard
				renderer.toneMapping = THREE.ReinhardToneMapping;
				renderer.toneMappingExposure = 3;

				// tweakons ça
				gui.add(renderer, "toneMapping", {
					No: THREE.NoToneMapping,
					Linear: THREE.LinearToneMapping,
					Reinhard: THREE.ReinhardToneMapping,
					Cineon: THREE.CineonToneMapping,
					ACESFilmicToneMapping: THREE.ACESFilmicToneMapping
				}).onFinishChange(() => {

					renderer.toneMapping = Number(renderer.toneMapping);
					updateAllMAterials();

				});

				gui.add(renderer, "toneMappingExposure").min(0).max(10).step(0.001);

				renderer.shadowMap.enabled = true;
				renderer.shadowMap.type = THREE.PCFSoftShadowMap;












				const controls = new OrbitControls(camera, this.$refs.canvas);
				controls.enableDamping = true;




				const clock = new THREE.Clock();

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					// sans ce .update() , le damping ne fonctionnera pas ! 
					controls.update();

					renderer.render(scene, camera);

					console.log("requestAnim is triggerd");

					this.animation.run && window.requestAnimationFrame(tick);

				};

				gui
					.add(this.animation, "run")
					.name("run animation");

				tick();


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