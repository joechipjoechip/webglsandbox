<template>
	<div>
		<canvas ref="wavecanvas"></canvas>
		hey wave component
	</div>
</template>

<script>

	import Wave from "./WebGL/wave-motion.js";

	export default {
		data(){
			return {

			}
		},
		mounted(){

			const scene = new Wave(this.$refs.wavecanvas);

			scene.init();

		}
	}
</script>

<style lang="scss" scoped>

</style>