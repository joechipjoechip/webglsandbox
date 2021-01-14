<template>
	<div>
		<!-- <p>hey</p> -->
		<div id="torus"></div>
	</div>
</template>

<script>

	import Gl from "@/components/WebGLFont/WebGLFontPlayground.js";

	export default {
		deta(){
			return  {

			}
		},
		mounted(){

			const gl = new Gl("yeet boiiiiii");
			
			gl.init();

		}

	}
</script>

<style lang="scss" scoped>

</style>