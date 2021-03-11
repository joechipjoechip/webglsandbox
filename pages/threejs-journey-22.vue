<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<div class="digCanvasContainer" ref="digCanvas"></div>
		<div class="waveCanvasContainer" ref="waveCanvas"></div>
		<div class="videoControls" ref="videoControls" :active="userIsWatching">
			<div class="left">
				<img class="button" src="/assets/video-ui/pause.png" alt="">
			</div>
			<div class="center">
				<div class="videoNav"></div>
			</div>
			<div class="right">
				<img class="button" src="/assets/video-ui/volume.png" alt="">
				<img class="button" src="/assets/video-ui/fullscreen.png" alt="">
				<img class="button" src="/assets/video-ui/exit.png" @click="stopWatching" alt="">
			</div>
		</div>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import * as dat from 'dat.gui';

	import gsap from 'gsap';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	import vertexShader from "./../components/shaders-homemade/sand/vertex.glsl";

	import fragmentShader from "./../components/shaders-homemade/sand/fragment.glsl";

	export default {
		data(){
			return {
				userIsWatching: false
			};
		},
		mounted(){

			this.animation = {
				run: true
			};

			this.cameraBaseY = 2;
			this.cameraBaseZ = 5;
			this.cameraBaseRotationX = Math.PI * -0.25;
			this.cameraIsMoving = false;

			this.cameraControlsEnabled = true;

			this.userIsWatching = false;

			this.isPositionningCamera = false;

			this.enoughtUnsanded = false;

			this.init();

		},

		methods: {

			onCanvasClick( event ){

				if( this.isHoveringScreen && this.enoughtUnsanded && !this.userIsWatching ){

					this.positionCameraToWatchVideo();

				}

			},

			positionCameraToWatchVideo(){

				// regarder le screen de manière smooth si pas de lookAt permanent de la camera
				// puis

				if( !this.cameraIsMoving ){

					this.cameraIsMoving = true;
	
					this.askVideoToPlay();

					// cette rotation ne peut pas avoir lieu puisque la camera .lookAt()
					// gsap.to(this.camera.rotation, {
					// 	duration: 3,
					// 	x: Math.PI / -2,
					// 	y: 0,
					// 	z: 0
					// });
	
					gsap
						.to(this.camera.position, {
							duration: 3,
							x: this.screen.position.x,
							y: this.screen.position.y + 3,
							z: this.screen.position.z,
							onComplete: () => {

								gsap.to(this.camera.position, {
									duration: 2,
									y: this.screen.position.y + 2,
									onComplete: () => {
	
										// this.isPositionningCamera = false;
										this.cameraIsMoving = false;
										
									}

								});

								this.userIsWatching = true;
	
								this.checkIfUserIsWatching();
	
							}
						});

				}


			},

			stopWatching(){

				this.userIsWatching = false;

				this.cameraControlsEnabled = true;


				if( !this.cameraIsMoving ){

					this.cameraIsMoving = true;

					gsap.to(this.camera.rotation, {
						duration: 0.5,
						x: this.cameraBaseRotationX,
						onComplete: () => {

							gsap.to(this.camera.position, {
								duration: 2,
								y: this.cameraBaseY,
								z: this.cameraBaseZ,
								onComplete: () => { this.cameraIsMoving = false; }
							});

						}
					});

				}

			},

			checkIfUserIsWatching(){

				if( this.userIsWatching ){

					this.cameraControlsEnabled = false;

				} else {

					this.cameraControlsEnabled = true;

				}
			
			},

			askVideoToPlay(){

				if( this.video.paused ){

					this.video.play();

				}
				// else {

				// 	this.video.pause();

				// }

			},

			onMouseWheel( event ){

				const deltaY = event.deltaY;
				const deltaYsmooth = Math.abs(deltaY * 0.001);

				if( deltaY < 0 ){
					// go up
					this.updateCameraPosition("up", deltaYsmooth);
				}
				else {
					// go down
					this.updateCameraPosition("down", deltaYsmooth);
				}

			},

			updateCameraPosition(direction, factor){

				if( !this.cameraControlsEnabled ){
					return;
				}

				// if( direction === "left" || direction === "right" ){
				// 	return;
				// }

				switch(direction){

					case "left":
						this.camera.position.x -= factor;
						break;

					case "right":
						this.camera.position.x += factor;
						break;

					case "up":
						// éviter le retournement des controls
						if( this.camera.position.z > 0.1 ){

							this.camera.position.z -= factor;
						}
						break;

					case "down":
						this.camera.position.z += factor;
						break;

				}

			},

			init(){

				// options :
				let sizes = {
					width: window.innerWidth,
					height: window.innerHeight
				};

				// NAV : 
				const cameraMoveThreshol = 0.6;
				let mouseIsMoving = false;
				let hoveringCount = 0;
				const hoveringThresold = 200;
				


				// SAND VARIABLES - - - - -
				const nbSubdivisions = 256;
				// for canvas dig
				const DIGCIRCLESIZE = 7;
				const DIGIMPACT = 4;
				let GRADIENTDIGAMOUNT = 25;

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
				this.$refs.canvas.addEventListener( 'wheel', this.onMouseWheel, false );

				this.$refs.canvas.addEventListener( 'click', this.onCanvasClick);

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

				this.sandPlane = new THREE.Mesh(
					sandGeometry,
					sandMaterial
				);

				this.sandPlane.rotation.x = Math.PI / -2;

				this.scene.add(this.sandPlane);



				// SCREEN
				this.video = document.createElement("video");
				this.video.src = "videos/test.mp4";
				this.video.load();
				// 640*360
				const videoWidthFormated = (640 / 640) * 4;
				const videoHeightFormated = (360 / 640) * 4;

				console.log("hey : ", videoWidthFormated);

				const screenGeometry = new THREE.PlaneGeometry(videoWidthFormated, videoHeightFormated, 1);

				// video.play();

				const videoTexture = new THREE.VideoTexture(this.video);
				const screenMaterial = new THREE.MeshBasicMaterial({ 
					map: videoTexture, 
					side: THREE.FrontSide, 
					toneMapped: false 
				});

				this.screen = new THREE.Mesh(screenGeometry, screenMaterial);

				this.scene.add(this.screen);

				this.screen.position.y = SCREENLEVEL;
				this.screen.rotation.x = Math.PI * -0.5;




				// Lights
				const spotlight = new THREE.SpotLight(0xffffff, 0.5, 10, Math.PI * 0.2, 1, 1);
				spotlight.position.y = 5;
				spotlight.position.x = -2;
				spotlight.position.z = -1;

				spotlight.target.position.set(
					this.screen.position.x,
					this.screen.position.y,
					this.screen.position.z
				);

				this.scene.add(spotlight);
				this.scene.add(spotlight.target);


				// this.scene.add(spotLight);

				// const pointLight2 = new THREE.PointLight(0xffffff, 1, 10, 1);
				// pointLight2.position.y = 3;
				// pointLight2.position.x = -2;
				// this.scene.add(pointLight2);


				// RAYCASTER
				const raycaster = new THREE.Raycaster();


				// Camera
				const aspectRatio = sizes.width / sizes.height;
				this.camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				this.camera.position.z = this.cameraBaseZ;
				this.camera.position.y = this.cameraBaseY;

				this.camera.rotation.x = this.cameraBaseRotationX;

				this.scene.add(this.camera);

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

					// if( this.cameraIsMoving ){
						this.camera.lookAt(this.screen.position);
					// }

					if (mouseIsMoving && mouse.x) {
						
						// RAYCASTER INTERSECTS (terraforming) - - - - - - - - -
						raycaster.setFromCamera( mouse, this.camera );

						const intersects = raycaster.intersectObjects( [this.sandPlane, this.screen] );

						this.isHoveringScreen = intersects.filter(intersection => intersection.object.uuid === this.screen.uuid).length > 0;

						const intersectData = intersects.filter(intersect => intersect.object.uuid === this.sandPlane.uuid)[0];

						// ici on va aller dessiner sur le digCanvas
						if( intersectData ){

							drawOnDigCanvas(intersectData.uv);

							if( hoveringCount < hoveringThresold ){
								hoveringScreenCounter(this.isHoveringScreen);
							}

							canvasDigTexture.needsUpdate = true;

							// drawOnWaveCanvas(intersectData.uv, elapsedTime);
							// canvasWaveTexture.needsUpdate = true;
							
						}


					}

					// NOW COMPUTE RENDER
					renderer.render(this.scene, this.camera);

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
	
						// // this.digCtx.save();
						// this.digCtx.fillStyle = `rgba(255,0,0,${DIGIMPACT * 0.0025})`;
						// // this.digCtx.beginPath();
						// this.digCtx.ellipse(x, y, DIGCIRCLESIZE, DIGCIRCLESIZE, 0, 0, 2 * Math.PI);
						// this.digCtx.fill();
						// // this.digCtx.restore();
						
						GRADIENTDIGAMOUNT = this.digCtx.createRadialGradient(x, y, 5, x, y, 15);
						GRADIENTDIGAMOUNT.addColorStop(0, 'rgba(255,0,0,0.03');
						GRADIENTDIGAMOUNT.addColorStop(1, 'rgba(0,0,0,	0.01)');

						this.digCtx.arc(x, y, 15, 0, 2 * Math.PI);
						this.digCtx.fillStyle = GRADIENTDIGAMOUNT;
						this.digCtx.fill();

						lastUv = uv;

					} else {

						this.digCtx.beginPath();

					}

				};

				let previousTime = 0;
				let previousUv = { x: 0.0, y: 0.0 };
				this.velocity = 0;

				// suspended
				const drawOnWaveCanvas = (uv, currentTime) => {
					
					const x = uv.x * this.waveCanvas.width;
					const y = (1 - uv.y) * this.waveCanvas.height;
					const waveDistanceMin = 80;

					//  n'est fait que s'il y a mouvement de la souris
					if( !(uv.x === previousUv.x && uv.y === previousUv.y) ){

						const timeDiff = currentTime - previousTime;
	
						// d=√((x_2-x_1)²+(y_2-y_1)²) 
						// const distance = Math.sqrt(Math.pow(uv.x - previousUv.x, 2) + Math.pow(uv.y - previousUv.y, 2));
						// const velocity = (distance / timeDiff) * 10;
						this.velocity = (Math.sqrt(Math.pow(uv.x - previousUv.x, 2) + Math.pow(uv.y - previousUv.y, 2)) / timeDiff) * 10;
						// console.log("vel : ", velocity.toFixed(0));
	
						const mouseInfos = {};
	
						if (uv.x <= previousUv.x) {

							// mouseInfos.directionX = "left"
							mouseInfos.diffX = (previousUv.x - uv.x) * 1000;

						} else if (uv.x >= previousUv.x) {

							// mouseInfos.directionX = "right"
							mouseInfos.diffX = (uv.x - previousUv.x) * 1000;

						}
	
						if (uv.y <= previousUv.y) {

							// mouseInfos.directionY = "top"
							mouseInfos.diffY = (previousUv.y - uv.y) * 1000;

						} else if (uv.y >= previousUv.y) {

							// mouseInfos.directionY = "bottom";
							mouseInfos.diffY = (uv.y - previousUv.y) * 1000;

						}

						// on a un max tendanciel de [4 - 6]
	
						// console.log("mouse : ", mouseInfos.diffX, mouseInfos.diffY);
	
						
						// console.log(this.velocity);
						// draw here
						// console.log("diffx : ", mouseInfos.diffX);
						if( this.velocity > 20 && ( mouseInfos.diffX > waveDistanceMin || mouseInfos.diffY > waveDistanceMin ) ){

							const currentX = uv.x * this.waveCanvas.width;
							const currentY = (1 - uv.y) * this.waveCanvas.height;

							const previousX = previousUv.x * this.digCanvas.width;
							const previousY = (1 - previousUv.y) * this.digCanvas.height;

							this.waveCtx.save();

							const grad = this.waveCtx.createLinearGradient(previousX, previousY, currentX, currentY);
							grad.addColorStop(1, "rgba(0,0,0,0");
							grad.addColorStop(0, "#0000FF");

							this.waveCtx.strokeStyle = grad;
							this.waveCtx.lineWidth = 8;

							this.waveCtx.beginPath();
							this.waveCtx.moveTo(previousX, previousY);
							this.waveCtx.lineTo(currentX, currentY);

							this.waveCtx.stroke();

							this.waveCtx.restore();

							// refresh here
							previousTime = currentTime;
							previousUv = { x: uv.x, y: uv.y };
	
						}

						// refresh here
						previousTime = currentTime;
						previousUv = { x: uv.x, y: uv.y };

					}







				};

				

				const hoveringScreenCounter = isHovering => {

					if( isHovering ){
						hoveringCount++;
					}

					checkIfEnoughUnsanded();

				};

				const checkIfEnoughUnsanded = () => {

					if(hoveringCount >= hoveringThresold ){

						this.enoughtUnsanded = true;

						this.positionCameraToWatchVideo();

					}

				};

				const checkIfCameraNeedToMove = cursor => {

					let movePower = 1;

					if( cursor.x > cameraMoveThreshol ){

						movePower =  Math.abs(cursor.x - cameraMoveThreshol);

						this.updateCameraPosition("right", 0.1 * movePower);

					} 

					if( cursor.x < -cameraMoveThreshol ){

						movePower =  Math.abs(cursor.x + cameraMoveThreshol);

						this.updateCameraPosition("left", 0.1 * movePower);

					}

					if( cursor.y > cameraMoveThreshol ){

						movePower =  Math.abs(cursor.y - cameraMoveThreshol) * 2;

						this.updateCameraPosition("up", 0.1 * movePower);

					} 

					if( cursor.y < -cameraMoveThreshol ){

						movePower =  Math.abs(cursor.x - cameraMoveThreshol) / 2;

						this.updateCameraPosition("down", 0.1 * movePower);

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
		display: flex;
		flex-flow: row nowrap;
		justify-content: center;
		align-items: center;
		bottom: -150px;
		width: 50%;
		left: calc(100% - 75%);
		border-radius: 8px 8px 0 0;
		height: 60px;
		background-color: rgba(0,0,0,0);

		transition: 
			bottom 2.5s,
			background-color 4s;

		&[active="true"] {
			bottom: 0px;
			background-color: rgba(0,0,0,0.6);
		}

		img {
			height: 100%;
			cursor: pointer;
		}

		.left,
		.center,
		.right {
			height: 50%;
		}

		.center {
			width: 60%;
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: center;
			margin: 0 25px;

			.videoNav {
				width: 100%;
				height: 5px;
				background-color: rgba(255,255,255,0.6);
				border-radius: 999px;
			}

		}

		.right {
			& > * {
				margin-right: 25px;

				&:last-of-type {
					margin: 0;
				}
			}
		}

	}


	p {
		color: white;
		z-index: 5;
	}

</style>