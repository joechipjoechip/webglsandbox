<template>
	<div>
		<p>hey three journey 1 : la baase</p>
		<canvas class="webgl" ref="canvas"></canvas>
	</div>
</template>

<script>

	import * as THREE from 'three';

	export default {
		data(){
			return {};
		},

		mounted(){

			console.log("hey hey ", THREE);

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

				// Basic element
				const geometry = new THREE.BoxGeometry(1,1,1);
				const material = new THREE.MeshBasicMaterial({ color: "#ff0000" });
				const mesh = new THREE.Mesh(geometry, material);

				// then add it to the scene
				scene.add(mesh);


				// Camera
				const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height);
				camera.position.z = 3;

				// then add it to the scene
				scene.add(camera);


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