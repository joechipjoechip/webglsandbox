<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 28, importer un model blender baked</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js"

	import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js';

	import firefliesVertexShader from "./../components/shaders-homemade/fireflies/vertex.glsl";

	import firefliesFragmentShader from "./../components/shaders-homemade/fireflies/fragment.glsl";


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

				// LOADERS

				const textureLoader = new THREE.TextureLoader();

				// DRACO loader
				// si on a compressé le model à l'export dans blender, on aura besoin d'un DRACOLoader
				const dracoLoader = new DRACOLoader();
				dracoLoader.setDecoderPath("draco/");

				// ATTENTION : ne pas oublier d'aller copier les fichier .js qui se trouvent dans static/draco

				// GLTF loader
				const gltfLoader = new GLTFLoader();
				gltfLoader.setDRACOLoader(dracoLoader);

				// Textures
				const bakedTexture = textureLoader.load("/blender/tuto/bakedBetter.jpg");

				// obligé d'inversé
				bakedTexture.flipY = false;

				// on restandardise l'encodage
				// (ne pas oublier d'également le spécifier au renderer)
				bakedTexture.encoding = THREE.sRGBEncoding;



				// BASE : 
				// Scene
				const scene = new THREE.Scene();


				// MATERIALS
				// baked materials
				const bakedMaterial = new THREE.MeshBasicMaterial({
					map: bakedTexture
				});

				// pole lamp material
				const poleLightMaterial = new THREE.MeshBasicMaterial({ color: 0xffffe5 });
				const portalMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff });


				// MODEL
				gltfLoader.load(
					"/blender/tuto/merged.glb",
					(gltf) => {
						console.log("succeed : ", gltf);

						// ne pas confondre la "scene" de THREE avec la "scene" d'un model importé
						// le scene d'un model est un group qui est un ensemble des éléments qui constituent le model

						// gltf.scene.traverse((child) => {
						// 	// .traverse() sur la scene d'un gltf permet de parcourir tous les children de manière récursive (child dans le child dans le child etc..)
						// 	child.material = bakedMaterial;
						// });

						// mais maintenant que tous les models sont fusionnés en une seul géometry :
						const bigGeometry = gltf.scene.children.find(child => child.name === "merged");

						const poleLight1Mesh = gltf.scene.children.find((child) => child.name === "poleLight1");

						const poleLight2Mesh = gltf.scene.children.find((child) => child.name === "poleLight2");

						const portalMesh = gltf.scene.children.find((child) => child.name === "portalCircleCircle");

						bigGeometry.material = bakedMaterial;

						poleLight1Mesh.material = poleLightMaterial;
						poleLight2Mesh.material = poleLightMaterial;
						portalMesh.material = portalMaterial;
						 

						scene.add(gltf.scene);

					}
				);

				// fireflies
				// geo
				const firefliesGeometry = new THREE.BufferGeometry();
				const firefliesCount = 30;
				const positionArray = new Float32Array(firefliesCount * 3);

				for(let i = 0; i < firefliesCount; i++){
					positionArray[i * 3 + 0] = (Math.random() - 0.5) * 4;
					positionArray[i * 3 + 1] = Math.random() * 4;
					positionArray[i * 3 + 2] = (Math.random() - 0.5) * 4;
				}

				firefliesGeometry.setAttribute("position", new THREE.BufferAttribute(positionArray, 3));

				// material
				const firefliesMaterial = new THREE.ShaderMaterial({
					vertexShader: firefliesVertexShader,
					fragmentShader: firefliesFragmentShader
				});

				// points
				const fireflies = new THREE.Points(firefliesGeometry, firefliesMaterial);

				// scene.add(fireflies);





				// Camera
				const aspectRatio = sizes.width / sizes.height;
				const camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				camera.position.z = 5;

				// then add it to the scene
				scene.add(camera);


				// Axes helper : 
				// const axesHelper = new THREE.AxesHelper(2);
				// scene.add(axesHelper);

				// Renderer
				const renderer = new THREE.WebGLRenderer({
					canvas: this.$refs.canvas,

					// ne peut pas être déclaré en dehors de l'instanciation
					antialias: true
				});


				renderer.setSize(sizes.width, sizes.height);

				renderer.outputEncoding = THREE.sRGBEncoding;

				debugObject.clearColor = "#000000";

				renderer.setClearColor(debugObject.clearColor);

				gui
					.addColor(debugObject, "clearColor")
					.onChange(() => {
						
						renderer.setClearColor(debugObject.clearColor);
						
					});
				










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