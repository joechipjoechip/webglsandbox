<template>
	<div>
		<canvas ref="wavecanvas"></canvas>
	</div>
</template>

<script>

	import Wave from "./WebGL/wave-motion.js";

	// import img from "./images/texture.jpg";

	export default {
		data(){
			return {

			}
		},
		mounted(){

			const scene = new Wave(this.$refs.wavecanvas, "/images/texture.jpg");

			scene.init();

		}
	}
</script>

<style lang="scss" scoped>

</style>