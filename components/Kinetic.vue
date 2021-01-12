<template>
	<div>
		<p>hey</p>
		<canvas id="app"></canvas>
	</div>
</template>

<script>

	import WebGLFont from "@/components/WebGLFont/WebGLFont";
	import { shaders } from "@/components/WebGLFont/shaders";

	// import * as THREE from 'three';
	// global.THREE = THREE;

	export default {
		deta(){
			return  {

			}
		},
		mounted(){

			const type = new WebGLFont({
				word: "FALLING",
				position: [-90, -10, 0],
				rotation: [Math.PI, 0, 0],
				zoom: 150,
				vertex: shaders[0].vertex,
				fragment: shaders[0].fragment
			});

		}

	}
</script>

<style lang="scss" scoped>

</style>