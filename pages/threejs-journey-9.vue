<template>
	<div>
		<canvas class="webgl" ref="canvas"></canvas>
		<p>hey three journey 9, les textes 3d</p>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import gsap from 'gsap';

	import * as dat from 'dat.gui';

	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	import typeFaceFont from "~/assets/font/helvetiker_regular.typeface.json";

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

				// gui.hide();
				// le gui sera caché de base, pour l'afficher il faudra taper "h"

				const parameters = {
					color: 0xff0000,
					spin: () => {
						console.log("spinn triggered");
						gsap.to(mesh.rotation, {
							duration: 2,
							y: mesh.rotation.y + 10
						});
					}
				};


				// BASE : 
				// Scene
				const scene = new THREE.Scene();

				const ambientLight = new THREE.AmbientLight(0xffffff, 0.9);

				// Textures :
				const textureLoader = new THREE.TextureLoader();
				const matcapTexture = textureLoader.load("/images/exomaterials/textures/matcaps/8.png");

				// TEXTES : 
				// pour convertir une font au format propice pour three :
				// google : facetype.js sur github
				// générateur en ligne

				// on peut trouver des fonts directement utilisables dans three à 
				// /node_modules/three/examples/fonts

				// mais il vaut mieux copier la font dans /assets/ et la charger comme ceci :
				// import typeFaceFont from "~/assets/font/helvetiker_regular.typeface.json";
				// rappel : webpack, pour les imports, a accès à assets comme ci dessus
				// mais n'aura pas accès à static (limitation nuxtjs)

				// mais comme on va utiliser le fontLoader de Three, en fait, on ne passera pas par webpack
				// donc : la font peut être stockée dans /static/
				const fontLoader = new THREE.FontLoader();
				fontLoader.load(
					"/font/helvetiker_regular.typeface.json",
					(font) => {

						console.log("font : ", font);

						const textGeometry = new THREE.TextBufferGeometry(
							"hello worldy",
							{
								font,
								size: 0.5,
								// profondeur
								height: 0.2,
								curveSegments: 3,
								bevelEnabled: true,
								bevelThickness: 0.03,
								bevelSize: 0.02,
								bevelOffset: 0,
								bevelSegments: 3
							}
						);

						const textMaterial = new THREE.MeshMatcapMaterial({ matcap: matcapTexture });
						const text = new THREE.Mesh(textGeometry, textMaterial);

						// sans .computeBoundingBox()
						textGeometry.computeBoundingBox();
						// on a pas accès à textGeometry.boundingBox

						// .translate() vient de l'héritage : BufferGeometry -> ExtrudedBuggerGeometry -> TextGeometry
						// textGeometry.translate(
						// 	textGeometry.boundingBox.max.x * -0.5,
						// 	textGeometry.boundingBox.max.y * -0.5,
						// 	textGeometry.boundingBox.max.z * -0.5
						// );
						// la déclaration ci dessus donnera un resultat presque juste mais pas parfait
						// car elle ne tient pas compte du "bevel" (biseautage)
						// donc pour avoir du parfait, il faut intégrer les infos de bevel dans les calculs :

						// textGeometry.translate(
						// 	(textGeometry.boundingBox.max.x - 0.02) * -0.5,
						// 	(textGeometry.boundingBox.max.y - 0.02) * -0.5,
						// 	(textGeometry.boundingBox.max.z - 0.03) * -0.5
						// );

						// les biseaux correspondant à x et y sont : bevelSize
						// le biseau correspondant à z est : bevelThickness

						// mais en fait : c'était la manière compliqué et détaillée pour centrer la geometry dans sa boundingBox
						// en vrai, il existe un moyen bcp plus simple et rapide pour ce faire : 

						textGeometry.center();

						// tadaaa..
						// mais bon, c'était important de comprendre le fonctionnement de cette boundingBox (et ses biais potentiels (bevel))


						// Maintenant : ajoutons un matcap material (au moment de l'instanciation du material, plus haut)

						// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
						// et créons 100 donuts avec des positions randoms (?)
						// for(let i = 0; i < 100; i++){
							
						// 	const donutGeometry = new THREE.TorusBufferGeometry(0.3, 0.2, 20, 45);
						// 	const donutMaterial = new THREE.MeshMatcapMaterial({ matcap: matcapTexture });
						// 	const donut = new THREE.Mesh(donutGeometry, donutMaterial);

						// 	donut.position.set(
						// 		(Math.random() - 0.5) * 10,
						// 		(Math.random() - 0.5) * 10,
						// 		(Math.random() - 0.5) * 10
						// 	);

						// 	donut.rotation.set(
						// 		(Math.random() - 0.5) * Math.PI,
						// 		(Math.random() - 0.5) * Math.PI,
						// 		(Math.random() - 0.5) * Math.PI
						// 	);

						// 	const randomSize = Math.random();

						// 	donut.scale.set(
						// 		randomSize,
						// 		randomSize,
						// 		randomSize
						// 	);

						// 	scene.add(donut);

						// }
						// donc ok, c'est bien, mais pas opti du tout
						// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

						// rappel : on peut utiliser la même geometry et le même material pour plusieurs meshs

						// donc : 
						const donutGeometry = new THREE.TorusBufferGeometry(0.3, 0.2, 20, 45);
						const donutMaterial = new THREE.MeshMatcapMaterial({ matcap: matcapTexture });

						for(let i = 0; i < 100; i++){
							
							const donut = new THREE.Mesh(donutGeometry, donutMaterial);

							donut.position.set(
								(Math.random() - 0.5) * 10,
								(Math.random() - 0.5) * 10,
								(Math.random() - 0.5) * 10
							);

							donut.rotation.set(
								(Math.random() - 0.5) * Math.PI,
								(Math.random() - 0.5) * Math.PI,
								(Math.random() - 0.5) * Math.PI
							);

							const randomSize = Math.random();

							donut.scale.set(
								randomSize,
								randomSize,
								randomSize
							);

							scene.add(donut);

						}

						// on passe ainsi de 240ms pour génerer les donuts à 15ms (pour donner une idée)
						// enfin, si on veut vraiment opti, on voit que le donutMaterial est équivalent au textMaterial
						// on peut donc se passer de l'instanciation du donutMaterial et utiliser textMaterial à la place
						// (mais je le laisse pour que les test précédents puissent continuer de fonctionner avec le code précédent (commenté))




						scene.add(text, ambientLight);

					}
				);

				














				// Camera
				const aspectRatio = sizes.width / sizes.height;
				const camera = new THREE.PerspectiveCamera(75, aspectRatio, 0.1, 100);
				camera.position.z = 3;

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

				const controls = new OrbitControls(camera, this.$refs.canvas);
				controls.enableDamping = true;




				const clock = new THREE.Clock();

				// Animation
				const tick = () => {

					const elapsedTime = clock.getElapsedTime();

					// sans ce .update() , le damping ne fonctionnera pas ! 
					controls.update();



					// update des meshs
					// cube.rotation.y = 0.1 * elapsedTime;

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