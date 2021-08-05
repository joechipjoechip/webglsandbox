<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<div v-show="params.digInfos.displayCanvas" class="digCanvasContainer" ref="digCanvasContainer">
			<canvas ref="digCanvas"></canvas>
		</div>
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

	export default {
		data(){
			return {
				userIsWatching: false,
				params: {
					lights: {
						ambientLight: {
							color: 0x000099,
							intensity: 0.45
						},
						spotlight1: {
							color: 0xaa00ff,
							intensity: 1,
							distance: 7,
							angle: 1.12,
							penumbra: 1,
							decay: 0.2
						},
						spotlight2: {
							color: 0x0000ff,
							intensity: 1.75,
							distance: 11,
							angle: Math.PI * 0.3,
							penumbra: 1,
							decay: 1
						}
					},
					digInfos: {
						circleSizeInner: 1,
						circleSizeOuter: 12,
						impact: 0.03,
						gradientAmount: 25,
						displayCanvas: false
					},
					sandMaterial: {
						specular: 0xffffff
					}
				}
			};
		},
		mounted(){

			this.animation = {
				run: true
			};

			this.sandPlaneWidth = 10;

			this.displacementScale = 0.3;

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

			// onMouseWheel( event ){

			// 	const deltaY = event.deltaY;
			// 	const deltaYsmooth = Math.abs(deltaY * 0.001);

			// 	if( deltaY < 0 ){
			// 		// go up
			// 		this.updateCameraPosition("up", deltaYsmooth);
			// 	}
			// 	else {
			// 		// go down
			// 		this.updateCameraPosition("down", deltaYsmooth);
			// 	}

			// },

			updateLightPosition(uv){

				// this.spotlight2.position.x = (uv.x - 0.5) * (this.sandPlaneWidth / 2) * -1;
				// this.spotlight2.position.z = (uv.y - 0.5) * (this.sandPlaneWidth / 2);

				this.spotlight1.target.position.set(
					(uv.x - 0.5) * (this.sandPlaneWidth / 2),
					this.screen.position.y,
					(uv.y - 0.5) * (this.sandPlaneWidth / 2) * -1
				);

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
				const nbSubdivisions = 128;
				// for canvas dig
				const DIGCIRCLESIZEINNER = 2;
				const DIGCIRCLESIZEOUTER = 12;
				const DIGIMPACT = 4;
				let GRADIENTDIGAMOUNT = 0;

				const SCREENLEVEL = -0.3;
				// for uniformes
				const DEEPMAX = Math.abs(SCREENLEVEL) + 0.01 + this.displacementScale;

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

				const getRandom = (min, max) => {
					return Math.random() * (max - min) + min;
				};



				// Canvas qui va récup les position de la souris
				this.digCanvas = this.$refs.digCanvas;
				this.digCtx = this.digCanvas.getContext('2d');
				this.digCanvas.width = 200;
				this.digCanvas.height = 200;
				// this.$refs.digCanvasContainer.append(this.digCanvas);

				const canvasDigTexture = new THREE.CanvasTexture(this.digCanvas);
				
				// this.waveCanvas = document.createElement("canvas");
				// this.waveCtx = this.waveCanvas.getContext('2d');
				// this.waveCanvas.width = 200;
				// this.waveCanvas.height = 200;
				// // this.$refs.waveCanvas.append(this.waveCanvas);

				// const canvasWaveTexture = new THREE.CanvasTexture(this.waveCanvas);

				// SETUP
				this.scene = new THREE.Scene();

				// SANDPLANE
				const textureLoader = new THREE.TextureLoader();
				const sandVersion = "7-2";

				const sandTextureColor = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_COLOR.jpg`);
				const sandTextureNormal = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_NRM.jpg`);
				const sandTextureOcclusion = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_OCC.jpg`);
				const sandTextureRoughness = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_OCC.jpg`);
				const sandTextureDisp = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_DISP.png`);
				const sandTextureSpec = textureLoader.load(`images/textures/sand${sandVersion}/Sand_00${sandVersion}_SPEC.png`);

				const sandMaterial = new THREE.MeshPhongMaterial({
					map: sandTextureColor,
					normalMap: sandTextureNormal,
					aoMap: sandTextureOcclusion,
					roughnessMap: sandTextureRoughness,
					displacementMap: sandTextureDisp,
					displacementScale: this.displacementScale,
					specular: this.params.sandMaterial.specular,
					specularMap: sandTextureSpec
				});

				const depthMaterial = new THREE.MeshDepthMaterial({
					depthPacking: THREE.RGBADepthPacking
				});

				// now let's fusion this standard/phong material with our custom shader :
				sandMaterial.onBeforeCompile = shader => {

					shader.uniforms.uCanvasDigTexture = { value: canvasDigTexture };
					shader.uniforms.uDeepMax = { value: DEEPMAX };
					shader.uniforms.uTexture = { value: sandTextureColor };

					// VERTEX
					shader.vertexShader = shader.vertexShader.replace(
						"#include <common>",
						`
							#include <common>

							uniform float uDeepMax;

							uniform sampler2D uCanvasDigTexture;

							varying float vDigness;

						`
					);

					shader.vertexShader = shader.vertexShader.replace(
						"#include <beginnormal_vertex>",
						`
							#include <beginnormal_vertex>

							float digRed = texture2D(uCanvasDigTexture, uv).r;
							float digAlpha = texture2D(uCanvasDigTexture, uv).a;
							float currentDignessImpact = digRed * digAlpha;
							float amountToDig = min(currentDignessImpact, uDeepMax);

							objectNormal.z -= amountToDig;

						`
					);

					shader.vertexShader = shader.vertexShader.replace(
						"#include <begin_vertex>",
						`
							#include <begin_vertex>

							transformed.z -= amountToDig;

							vUv = uv;

							vDigness = currentDignessImpact;

						`
					);

					// FRAGMENT
					shader.fragmentShader = shader.fragmentShader.replace(
						"#include <common>",
						`
							#include <common>

							uniform sampler2D uTexture;

							varying float vDigness;

						`
					);

					shader.fragmentShader = shader.fragmentShader.replace(
						"#include <color_fragment>",
						`
							#include <color_fragment>

							vec4 textureColor = texture2D(uTexture, vUv);

							textureColor.rgb -= vDigness;

							diffuseColor = vec4(textureColor.rgb, 1.0);

						`
					);
					
				};

				// let's update the customDepthMaterial as well
				depthMaterial.onBeforeCompile = shader => {

					shader.uniforms.uCanvasDigTexture = { value: canvasDigTexture };
					shader.uniforms.uDeepMax = { value: DEEPMAX };

					shader.vertexShader = shader.vertexShader.replace(
						"#include <common>",
						`
							#include <common>

							uniform float uDeepMax;

							uniform sampler2D uCanvasDigTexture;

						`
					);

					shader.vertexShader = shader.vertexShader.replace(
						"#include <begin_vertex>",
						`
							#include <begin_vertex>

							float digRed = texture2D(uCanvasDigTexture, uv).r;
							float digAlpha = texture2D(uCanvasDigTexture, uv).a;
							float currentDignessImpact = digRed * digAlpha;
							float amountToDig = min(currentDignessImpact, uDeepMax);

							transformed.z -= amountToDig;

						`
					);

				};

				const sandGeometry = new THREE.PlaneGeometry(this.sandPlaneWidth, this.sandPlaneWidth, nbSubdivisions, nbSubdivisions);

				this.sandPlane = new THREE.Mesh(
					sandGeometry,
					sandMaterial
				);

				// ajoutons la cutomDepthMaterial au mesh
				// (c'est ça qui va gérer les core shadows (non pas les ombres portées, mais les ombres sur le mesh lui même))
				this.sandPlane.customDepthMaterial = depthMaterial;

				this.sandPlane.rotation.x = Math.PI / -2;

				this.scene.add(this.sandPlane);



				// SCREEN
				this.video = document.createElement("video");
				this.video.src = "videos/test.mp4";
				this.video.load();
				// 640*360
				const videoWidthFormated = (640 / 640) * 4;
				const videoHeightFormated = (360 / 640) * 4;

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
				this.ambientLight = new THREE.AmbientLight(
					this.params.lights.ambientLight.color, 
					this.params.lights.ambientLight.intensity
				);

				this.scene.add(this.ambientLight);

				this.spotlight1 = new THREE.SpotLight(
					this.params.lights.spotlight1.color, 
					this.params.lights.spotlight1.intensity, 
					this.params.lights.spotlight1.length, 
					this.params.lights.spotlight1.angle, 
					this.params.lights.spotlight1.penumbra, 
					this.params.lights.spotlight1.decay
				);

				this.spotlight1.position.y = 3;

				this.scene.add(this.spotlight1);

				this.scene.add(this.spotlight1.target);

				this.spotlight2 = new THREE.SpotLight(
					this.params.lights.spotlight2.color, 
					this.params.lights.spotlight2.intensity, 
					this.params.lights.spotlight2.length, 
					this.params.lights.spotlight2.angle, 
					this.params.lights.spotlight2.penumbra, 
					this.params.lights.spotlight2.decay
				);

				this.spotlight2.position.y = 0.5;
				this.spotlight2.position.z = 5.5;

				this.scene.add(this.spotlight2);

				// this.spotlightHelper = new THREE.SpotLightHelper(this.spotlight);
				// this.scene.add(this.spotlightHelper);

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
				const controls = new OrbitControls(this.camera, this.$refs.canvas);
				controls.enableDamping = true;

				const clock = new THREE.Clock();

				let oldElapsedTime = 0;

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					const deltaTime = elapsedTime - oldElapsedTime;

					oldElapsedTime = elapsedTime;

					// suspended :
					// checkIfCameraNeedToMove(mouse);

					// sans ce .update() , le damping ne fonctionnera pas ! 
					controls.update();

					// if( this.cameraIsMoving ){
						// this.camera.lookAt(this.screen.position);
					// }

					if (mouseIsMoving && mouse.x) {
						
						// RAYCASTER INTERSECTS (terraforming) - - - - - - - - -
						raycaster.setFromCamera( mouse, this.camera );

						const intersects = raycaster.intersectObjects( [this.sandPlane, this.screen] );

						this.isHoveringScreen = intersects.filter(intersection => intersection.object.uuid === this.screen.uuid).length > 0;

						const intersectData = intersects.filter(intersect => intersect.object.uuid === this.sandPlane.uuid)[0];

						// ici on va aller dessiner sur le digCanvas
						if( intersectData ){

							drawOnDigCanvas(intersectData.uv, this.isHoveringScreen);

							this.updateLightPosition(intersectData.uv);

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

				const drawOnDigCanvas = (uv, isHoveringScreen) => {


					if( lastUv.x.toFixed(3) !== uv.x.toFixed(3) && 
						lastUv.y.toFixed(3) !== uv.y.toFixed(3))
					{

						const x = uv.x * this.digCanvas.width;
						const y = (1 - uv.y) * this.digCanvas.height;
						const opacity = isHoveringScreen ? this.params.digInfos.impact * 2 : this.params.digInfos.impact;

						this.params.digInfos.gradientAmount = this.digCtx.createRadialGradient(
							x, y, 
							this.params.digInfos.circleSizeInner, 
							x, y, 
							this.params.digInfos.circleSizeOuter
						);

						this.params.digInfos.gradientAmount.addColorStop(0, `rgba(255,0,0, ${opacity}`);
						this.params.digInfos.gradientAmount.addColorStop(1, 'rgba(255,0,0, 0.0)');

						this.digCtx.arc(x, y, this.params.digInfos.circleSizeOuter, 0, Math.PI * 2);
						this.digCtx.fillStyle = this.params.digInfos.gradientAmount;
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
	
						// d = √((x_2-x_1)²+(y_2-y_1)²) 
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

				// suspended : (quand la mouse s'approche des bords d'écran on décale la cam)
				// const checkIfCameraNeedToMove = cursor => {

				// 	let movePower = 1;

				// 	if( cursor.x > cameraMoveThreshol ){

				// 		movePower =  Math.abs(cursor.x - cameraMoveThreshol);

				// 		this.updateCameraPosition("right", 0.1 * movePower);

				// 	} 

				// 	if( cursor.x < -cameraMoveThreshol ){

				// 		movePower =  Math.abs(cursor.x + cameraMoveThreshol);

				// 		this.updateCameraPosition("left", 0.1 * movePower);

				// 	}

				// 	if( cursor.y > cameraMoveThreshol ){

				// 		movePower =  Math.abs(cursor.y - cameraMoveThreshol) * 2;

				// 		this.updateCameraPosition("up", 0.1 * movePower);

				// 	} 

				// 	if( cursor.y < -cameraMoveThreshol ){

				// 		movePower =  Math.abs(cursor.x - cameraMoveThreshol) / 2;

				// 		this.updateCameraPosition("down", 0.1 * movePower);

				// 	}


				// };

				gui
					.add(this.animation, "run")
					.name("run animation");

			
				const guiSpotLight = (elementName) => {

					const folder = gui.addFolder(elementName);

					folder
						.addColor(this.params.lights[elementName], "color")
						.onChange(() => {
							this[elementName].color.set(this.params.lights[elementName].color);
						})
						.name("color");

					folder
						.add(this.params.lights[elementName], "intensity")
						.min(0).max(2).step(0.01)
						.onChange(() => {
							this[elementName].intensity = this.params.lights[elementName].intensity;
						})
						.name("intensity");
						
					folder
						.add(this.params.lights[elementName], "distance")
						.min(0).max(10).step(0.01)
						.onChange(() => {
							this[elementName].distance = this.params.lights[elementName].distance;
						})
						.name("distance");

					folder
						.add(this.params.lights[elementName], "angle")
						.min(Math.PI * -0.5).max(Math.PI * 0.5).step(0.01)
						.onChange(() => {
							this[elementName].angle = this.params.lights[elementName].angle;
						})
						.name("angle");

					folder
						.add(this.params.lights[elementName], "penumbra")
						.min(0).max(1).step(0.01)
						.onChange(() => {
							this[elementName].penumbra = this.params.lights[elementName].penumbra;
						})
						.name("penumbra");

				};

				const guiAmbientLight = (elementName) => {

					const folder = gui.addFolder(elementName);

					folder
						.addColor(this.params.lights[elementName], "color")
						.onChange(() => {
							this[elementName].color.set(this.params.lights[elementName].color);
						})
						.name("color");

					folder
						.add(this.params.lights[elementName], "intensity")
						.min(0).max(2).step(0.01)
						.onChange(() => {
							this[elementName].intensity = this.params.lights[elementName].intensity;
						})
						.name("intensity");

				};

				const guiDig = () => {

					const folder = gui.addFolder("Dig Infos");

					folder
						.add(this.params.digInfos, "circleSizeInner")
						.min(0).max(2).step(0.01)
						.name("circleSizeInner");

					folder
						.add(this.params.digInfos, "circleSizeOuter")
						.min(0).max(20).step(0.01)
						.name("circleSizeOuter");

					folder
						.add(this.params.digInfos, "impact")
						.min(0).max(0.2).step(0.01)
						.name("impact");

					folder
						.add(this.params.digInfos, "gradientAmount")
						.min(15).max(35).step(0.1)
						.name("gradientAmount");

					folder
						.add(this.params.digInfos, "displayCanvas")
						.name("display canvas");

				};

				const guiSandMaterial = () => {

					const folder = gui.addFolder("sand material");

					folder
						.addColor(this.params.sandMaterial, "specular")
						.onChange(() => {
							this.sandPlane.material.specular = new THREE.Color(this.params.sandMaterial.specular);
						})
						.name("specular");

				};


				// Add gui's
				const guiManager = () => {

					guiAmbientLight("ambientLight");

					guiSpotLight("spotlight1");
					guiSpotLight("spotlight2");

					guiDig();
					guiSandMaterial();

				};

				guiManager();

				
				// and launch
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
		top: 10px;
		left: 10px;
		border: dashed 1px rgba(255,255,255,0.3);
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