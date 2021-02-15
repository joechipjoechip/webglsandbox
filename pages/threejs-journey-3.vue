<template>
	<div>
		<p>hey three journey 3, animations</p>
		<p>requestAnimationFrame</p>
		<canvas class="webgl" ref="canvas"></canvas>
	</div>
</template>

<script>

	import * as THREE from 'three';

	import gsap from 'gsap';

	export default {
		mounted(){

			this.init();

		},

		methods: {

			init(){

				// options :
				const sizes = {
					width: 800,
					height: 600
				};


				// Scene
				const scene = new THREE.Scene();

				// Group :
				const group = new THREE.Group();
				group.position.y = -1;
				group.scale.y = 2;

				// fast way to create a mesh
				const cube1 = new THREE.Mesh(
					new THREE.BoxGeometry(1,1,1),
					new THREE.MeshBasicMaterial({ color: 0xff0000 })
				);

				const cube2 = new THREE.Mesh(
					new THREE.BoxGeometry(1,1,1),
					new THREE.MeshBasicMaterial({ color: 0x00ff00 })
				);
				cube2.position.x = 2;

				const cube3 = new THREE.Mesh(
					new THREE.BoxGeometry(1,1,1),
					new THREE.MeshBasicMaterial({ color: 0x0000ff })
				);
				cube3.position.x = -2;

				group.add(cube1);
				group.add(cube2);
				group.add(cube3);

				scene.add(group);


				// then add it to the scene
				// scene.add(mesh);
				scene.add(group);


				// Camera
				const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height);
				camera.position.z = 3;

				// camera.lookAt(mesh.position);
				// camera.lookAt(group.position);

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



				// Animations : 

				// 3 manières de gérer la temporalité :
				// 1 : faire un deltaTime entre le currentTime dans le tick et le time de l'ancien tick
				// et utiliser ce deltaTime comme multiplicateur des variables à update :

				// let time = Date.now();

				// const tick = () => {

				// 	console.log("tick");
				// 	// Time :
				// 	const currentTime = Date.now();
				// 	const deltaTime = currentTime - time;
				// 	time = currentTime;

				// 	// make updates
				// 	cube1.rotation.y += 0.002 * deltaTime;

				// 	// call renderer
				// 	renderer.render(scene, camera);

				// 	window.requestAnimationFrame(tick);

				// };

				

				// 2 : utiliser le elapsedTime (qui porte bien son nom)
				// et l'utiliser comme variable d'update :

				// const clock = new THREE.Clock();

				// const tick = () => {

				// 	console.log(gsap);

				// 	const elapsedTime = clock.getElapsedTime();

				// 	console.log("tick");

				// 	// make updates

				// 	// classic : 
				// 	// cube1.rotation.y = elapsedTime;

				// 	// on aura ici une révololution par seconde
				// 	// cube1.rotation.y = elapsedTime * Math.PI * 2;

				// 	// si on veut un mouvement de va-et-vient (une sinusoïde donc)
				// 	// voir sin(x) et cos(x) dans google pour voir la différence
				// 	// et essayons d'animer la position de la caméra
				// 	camera.position.y = Math.sin(elapsedTime);
				// 	camera.position.x = Math.cos(elapsedTime);

				// 	// en lui disant de rester focus sur le group
				// 	camera.lookAt(group.position);

				// 	// call renderer
				// 	renderer.render(scene, camera);

				// 	// window.requestAnimationFrame(tick);

				// };

				// tick();



				// 3 : version GSAP
				gsap.to(group.position, { duration: 1, delay: 1, x: 2 });

				const tick = () => {

					renderer.render(scene, camera);

					window.requestAnimationFrame(tick);

				};

				tick();



			}
		}
	}
</script>

<style lang="scss" scoped>

</style>