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

	import vertexShader from "./../components/shaders-homemade/01/vertex.glsl";

	import fragmentShader from "./../components/shaders-homemade/01/fragment.glsl";

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

				const parameters = {};

				const getRandom = (min, max) => {
					return Math.random() * (max - min) + min;
				};

				// SETUP
				this.scene = new THREE.Scene();

				// Texture
				const textureLoader = new THREE.TextureLoader();
				const flagTexture = textureLoader.load("images/textures/flag/frenchFlag.jpg");


				// const material = new THREE.MeshStandardMaterial({ color: 0xffffff });

				const material = new THREE.RawShaderMaterial({
					vertexShader,
					fragmentShader,
					// side: THREE.DoubleSide,
					// wireframe: true,
					// transparent: true,
					// flatShading: true,
					uniforms: {
						uFrequency: {
							// dans les anciennes versions de three, il fallait préciser le type : 
							// type: "float",
							// type: "f",
							// type: "vec2",
							// type: "v2",
							// ce n'est plus nécéssaire maintenant, mais on peut croiser ce legacy
							value: new THREE.Vector2(10, 5) 
						},
						uTime: { value: 0 },
						// uColor : on aurait pu passer un Vec3 (puisqu'il aurait pu stocker r/g/b)
						// mais on va utiliser THREE.Color()
						uColor: { value: new THREE.Color("orange") },
						uTexture: { value: flagTexture }
						// ici on peut passer le canvasTexture
						// canvasTexture: { value: canvasTexture }
					}
				});

				const geometry = new THREE.PlaneBufferGeometry(1,1,16,16);

				// console.log(geometry.attributes);
				// geometry.attributes.position -> positions des vertices
				// geometry.attributes.normal -> positions des dehors des vertices
				// geometry.attributes.uv -> positions des textures

				// let's tweak
				// un FloatArray fourni sa taille avec .count
				const count = geometry.attributes.position.count;

				// on créé des valeurs random, qu'on stock dans un FloatArray
				const randoms = new Float32Array(count);

				for(let i = 0; i < count; i++){
					randoms[i] = Math.random();
				}

				// on attribue les valeurs random dans .attributes mais avec une nouvelle clé : aRandom
				geometry.setAttribute("aRandom", new THREE.BufferAttribute(randoms, 1));



















				const plane = new THREE.Mesh(
					geometry,
					material
				);

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
				camera.position.y = 0;

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
					material.uniforms.uTime.value = elapsedTime;


					// NOW COMPUTE RENDER
					renderer.render(this.scene, camera);

					console.log("requestAnim is triggerd");

					this.animation.run && window.requestAnimationFrame(tick);

				};

				tick();
				
				gui.add(material.uniforms.uFrequency.value, "x").min(0).max(20).step(0.01).name("freq x");
				gui.add(material.uniforms.uFrequency.value, "y").min(0).max(20).step(0.01).name("freq y");

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