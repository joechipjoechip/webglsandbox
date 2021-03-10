<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<div class="digCanvasContainer" ref="digCanvas"></div>
		<div class="waveCanvasContainer" ref="waveCanvas"></div>
		<div class="videoControls" ref="videoControls">
			<p>ici les controllers de la vidéo</p>
		</div>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	import vertexShader from "./../components/shaders-homemade/sand/vertex.glsl";

	import fragmentShader from "./../components/shaders-homemade/sand/fragment.glsl";

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

				// NAV : 
				const cameraMoveThreshol = 0.75;
				let mouseIsMoving = false;
				let hoveringCount = 0;
				const hoveringThresold = 200;


				// SAND VARIABLES - - - - -
				const nbSubdivisions = 100;
				// for canvas dig
				const DIGCIRCLESIZE = 6;
				const DIGIMPACT = 2;

				const SCREENLEVEL = -0.3;
				// for uniformes
				const DEEPMAX = Math.abs(SCREENLEVEL) + 0.01;

				let mouse = new THREE.Vector2();
				
				const onDocumentMouseMove = ( event ) => {

					event.preventDefault();
					mouse.x = ( event.clientX / renderer.domElement.clientWidth ) * 2 - 1;
					mouse.y = - ( event.clientY / renderer.domElement.clientHeight ) * 2 + 1;

					mouseIsMoving = true;

				};

				const onDocumentMouseLeave = ( event ) => {

					mouseIsMoving = false;

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

				const parameters = {};

				const getRandom = (min, max) => {
					return Math.random() * (max - min) + min;
				};



				// Canvas invisible qui va récup les position de la souris
				this.digCanvas = document.createElement("canvas");
				this.digCtx = this.digCanvas.getContext('2d');
				this.digCanvas.width = 200;
				this.digCanvas.height = 200;
				this.$refs.digCanvas.append(this.digCanvas);

				const canvasDigTexture = new THREE.CanvasTexture(this.digCanvas);
				
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

				// const sandTextureNormal = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_NRM.jpg`);
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

				sandPlane.rotation.x = Math.PI / -2;

				this.scene.add(sandPlane);



				// SCREEN
				const video = document.createElement("video");
				video.src = "videos/test.mp4";
				video.load();
				// 640*360
				const videoWidthFormated = (640 / 640) * 4;
				const videoHeightFormated = (360 / 640) * 4;

				console.log("hey : ", videoWidthFormated);

				const screenGeometry = new THREE.PlaneGeometry(videoWidthFormated, videoHeightFormated, 1);

				// video.play();

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
				// const axesHelper = new THREE.AxesHelper(2);
				// this.scene.add(axesHelper);

				// Renderer
				const renderer = new THREE.WebGLRenderer({
					canvas: this.$refs.canvas
				});

				renderer.setSize(sizes.width, sizes.height);

				renderer.shadowMap.enabled = true;


				// CONTROLS
				// const controls = new OrbitControls(camera, this.$refs.canvas);
				// controls.enableDamping = true;

				const clock = new THREE.Clock();

				let oldElapsedTime = 0;

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					const deltaTime = elapsedTime - oldElapsedTime;

					oldElapsedTime = elapsedTime;

					checkIfCameraNeedToMove(mouse);

					// sans ce .update() , le damping ne fonctionnera pas ! 
					// controls.update();
					camera.lookAt(sandPlane.position);

					if (mouseIsMoving && mouse.x) {
						
						// RAYCASTER INTERSECTS (terraforming) - - - - - - - - -
						raycaster.setFromCamera( mouse, camera );

						// const intersects = raycaster.intersectObjects( [sandPlane, screen] );
						const intersects = raycaster.intersectObjects( [sandPlane, screen] );

						const isHoveringScreen = intersects.filter(intersection => intersection.object.uuid === screen.uuid).length > 0;

						const intersectData = intersects.filter(intersect => intersect.object.uuid === sandPlane.uuid)[0];

						// ici on va aller dessiner sur le digCanvas
						if( intersectData ){

							drawOnDigCanvas(intersectData.uv);

							if( hoveringCount < hoveringThresold ){
								hoveringScreenCounter(isHoveringScreen);
							}
							// drawOnWaveCanvas(intersectData.uv, elapsedTime);
							canvasDigTexture.needsUpdate = true;
							// canvasWaveTexture.needsUpdate = true;
						}


					}

					// NOW COMPUTE RENDER
					renderer.render(this.scene, camera);

					console.log("requestAnim is triggerd");

					this.animation.run && window.requestAnimationFrame(tick);

				};

				

				let lastUv = { x: 0.000, y: 0.000 };

				const drawOnDigCanvas = uv => {


					if( lastUv.x.toFixed(3) !== uv.x.toFixed(3) && 
						lastUv.y.toFixed(3) !== uv.y.toFixed(3))
					{

						const x = uv.x * this.digCanvas.width;
						const y = (1 - uv.y) * this.digCanvas.height;
	
						// this.digCtx.save();
						this.digCtx.fillStyle = `rgba(255,0,0,${DIGIMPACT * 0.0025})`;
						// this.digCtx.beginPath();
						this.digCtx.ellipse(x, y, DIGCIRCLESIZE, DIGCIRCLESIZE, 0, 0, 2 * Math.PI);
						this.digCtx.fill();
						// this.digCtx.restore();

						lastUv = uv;

					} else {

						this.digCtx.beginPath();

					}

				};

				

				const hoveringScreenCounter = isHovering => {

					if( isHovering ){
						hoveringCount++;
					}
					else {
						hoveringCount--;
					}

					checkIfPlayVideo();

				};

				const checkIfPlayVideo = () => {

					console.log("hovercount : ", hoveringCount);

					if(hoveringCount >= hoveringThresold ){

						askForVideoToPlay();

					}

				};

				const askForVideoToPlay = () => {

					if( !video.isPaused ){

						// ici faire apparaitre les controls du lecteur vidéo
						this.$refs.videoControls.setAttribute("active", "true");

						video.play();


						// rendre ça smooth (avec gsap trinks)
						camera.position.set(
							sandPlane.position.x,
							sandPlane.position.y + 2,
							sandPlane.position.z
						);

					}

				}

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

				const checkIfCameraNeedToMove = cursor => {

					let movePower = 1;

					if( cursor.x > cameraMoveThreshol ){

						movePower =  Math.abs(cursor.x - cameraMoveThreshol);

						updateCameraPosition("right", 0.1 * movePower);

					} 

					if( cursor.x < -cameraMoveThreshol ){

						movePower =  Math.abs(cursor.x + cameraMoveThreshol);

						updateCameraPosition("left", 0.1 * movePower);

					}

					if( cursor.y > cameraMoveThreshol ){

						movePower =  Math.abs(cursor.y - cameraMoveThreshol) * 2;

						updateCameraPosition("up", 0.1 * movePower);

					} 

					if( cursor.y < -cameraMoveThreshol ){

						movePower =  Math.abs(cursor.x - cameraMoveThreshol) / 2;

						updateCameraPosition("down", 0.1 * movePower);

					}


				};

				const updateCameraPosition = (direction, factor) => {

					switch(direction){
						case "left":
							camera.position.x -= factor;
							break;
						case "right":
							camera.position.x += factor;
							break;
						case "up":
							camera.position.z -= factor;
							break;
						case "down":
							camera.position.z += factor;
							break;
					}

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

	.videoControls {
		position: fixed;
		display: block;
		bottom: -150px;
		width: 100%;
		height: 60px;
		border: solid 1px white;

		transition: bottom 1s;

		&[active="true"] {
			bottom: 0px;
		}
	}


	p {
		color: white;
		z-index: 5;
	}

</style>