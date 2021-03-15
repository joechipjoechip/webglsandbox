<template>
	<div class="index-container">
		<nav>
			<nuxt-link to="/torus">torus</nuxt-link>
			<nuxt-link to="/kinetic">kinetic</nuxt-link>
			<nuxt-link to="/wave-motion">wave-motion</nuxt-link>
			<nuxt-link to="/threejs-journey-1">threejs journey #1 : base base</nuxt-link>
			<nuxt-link to="/threejs-journey-2">threejs journey #2 : les positions</nuxt-link>
			<nuxt-link to="/threejs-journey-3">threejs journey #3 : les anims</nuxt-link>
			<nuxt-link to="/threejs-journey-4">threejs journey #4 : les caméras</nuxt-link>
			<nuxt-link to="/threejs-journey-5">threejs journey #5 : les géométries</nuxt-link>
			<nuxt-link to="/threejs-journey-6">threejs journey #6 : la debug ui</nuxt-link>
			<nuxt-link to="/threejs-journey-7">threejs journey #7 : les textures</nuxt-link>
			<nuxt-link to="/threejs-journey-8">threejs journey #8 : les materials</nuxt-link>
			<nuxt-link to="/threejs-journey-9">threejs journey #9 : les textes 3d</nuxt-link>
			<nuxt-link to="/text3dtest">#9.1 : les tests textes 3d</nuxt-link>
			<nuxt-link to="/threejs-journey-10">threejs journey #10 : les lights</nuxt-link>
			<nuxt-link to="/threejs-journey-11">threejs journey #11 : les shadows</nuxt-link>
			<nuxt-link to="/threejs-journey-12">threejs journey #12 : les particules</nuxt-link>
			<nuxt-link to="/threejs-journey-13">threejs journey #13 : un galaxy generator</nuxt-link>
			<nuxt-link to="/threejs-journey-14">threejs journey #14 : le raycasting</nuxt-link>
			<nuxt-link to="/threejs-journey-15">threejs journey #15 : PHYSICS</nuxt-link>
			<nuxt-link to="/threejs-journey-16">threejs journey #16 : PHYSICS (factorisée)</nuxt-link>
			<nuxt-link to="/threejs-journey-17">threejs journey #17 : Test 2 renderer (with PHYSICS)</nuxt-link>
			<nuxt-link to="/threejs-journey-18">threejs journey #18 : Material video && sand shaders</nuxt-link>
			<nuxt-link to="/threejs-journey-19">threejs journey #19 : SHADERS</nuxt-link>
			<nuxt-link to="/threejs-journey-20">threejs journey #20 : SHADERS with uniforms</nuxt-link>
			<nuxt-link to="/threejs-journey-21">threejs journey #21 : Video + sand + particles</nuxt-link>
			<nuxt-link to="/threejs-journey-22">threejs journey #22 : Video + sand + canvas drawing mouse</nuxt-link>
			<nuxt-link to="/threejs-journey-23">threejs journey #23 : 50 shades of Shaders (patterns)</nuxt-link>
			<nuxt-link to="/threejs-journey-24">threejs journey #24 : Shader : raging sea</nuxt-link>
			<nuxt-link to="/threejs-journey-25">threejs journey #25 : Hooking custom shader with standard shader</nuxt-link>
		</nav>
	</div>
</template>

<script>
	
	export default {

	}

</script>

<style lang="scss" scoped>

	.index-container {
		display: flex;
		flex-direction: column;
		justify-content: center;
		height: 100vh;
	}

	nav {
		display: flex;
		flex-direction: column;
		width: 80%;
		margin: 0 auto;
		text-align: center;

		& > * {
			text-transform: capitalize;
		}
	}

</style>
