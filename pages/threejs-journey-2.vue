<template>
	<div>
		<p>hey three journey 2, les positions / scale / rotate</p>
		<p>Vector3 and Euler (and groups)</p>
		<canvas class="webgl" ref="canvas"></canvas>
	</div>
</template>

<script>

	import * as THREE from 'three';

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


				// Basic element
				// const geometry = new THREE.BoxGeometry(1,1,1);
				// const material = new THREE.MeshBasicMaterial({ color: "#ff0000" });
				// const mesh = new THREE.Mesh(geometry, material);

				// // Remind : position and scale works with Vector3
				// // (actually, mesh.position --> is a Vector3)
				// // Position : 2 ways :
				// mesh.position.y = 1;
				// mesh.position.x = 1;
				// // or
				// mesh.position.set(1,1,0);

				// // Scale : 2 ways :
				// mesh.scale.x = 2;
				// // or
				// mesh.scale.set(2,1,1);


				// Remind : Rotation works with Euler
				// Rotations :

				// give threejs the order of rotations
				// mesh.rotation.reorder("YXZ");

				// mesh.rotation.x = Math.PI * 0.25;
				// mesh.rotation.y = Math.PI * 0.75;









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

				renderer.render(scene, camera);


			}
		}
	}
</script>

<style lang="scss" scoped>

</style>