<template>
	<div>
		<!-- <p>hey</p> -->
		<div id="torus"></div>
		<canvas id="app"></canvas>
	</div>
</template>

<script>

	import WebGLFont from "@/components/WebGLFont/WebGLFont";
	import { shaders } from "@/components/WebGLFont/shaders";

	import Gl from "@/components/WebGLFont/WebGLFontPlayground.js";

	// import * as THREE from 'three';
	// global.THREE = THREE;

	export default {
		deta(){
			return  {

			}
		},
		mounted(){

			// const type = new WebGLFont({
			// 	word: "Hey boiiii",
			// 	position: [-90, -10, 0],
			// 	rotation: [Math.PI, 0, 0],
			// 	zoom: 150,
			// 	vertex: shaders[0].vertex,
			// 	fragment: shaders[0].fragment
			// });

			// - -  2nd version

			// const type = new WebGLFont({
			// 	word: "Hey boiiii",
			// 	position: [-90, -10, 0],
			// 	rotation: [Math.PI, 0, 0],
			// 	zoom: 150,
			// 	vertex: shaders.vertex[1],
			// 	fragment: shaders.fragment[1]
			// });

			// - - - 3rd version

			const gl = new Gl();
			
			gl.init();

		}

	}
</script>

<style lang="scss" scoped>

</style>