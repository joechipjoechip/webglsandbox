<template>
	<div class="index-container">
		<nav>
			<router-link to="/torus">torus</router-link>
			<router-link to="/kinetic">kinetic</router-link>
			<router-link to="/wave-motion">wave-motion</router-link>
			<router-link to="/threejs-journey-1">threejs journey #1 : base base</router-link>
			<router-link to="/threejs-journey-2">threejs journey #2 : les positions</router-link>
			<router-link to="/threejs-journey-3">threejs journey #3 : les anims</router-link>
			<router-link to="/threejs-journey-4">threejs journey #4 : les caméras</router-link>
			<router-link to="/threejs-journey-5">threejs journey #5 : les géométries</router-link>
			<router-link to="/threejs-journey-6">threejs journey #6 : la debug ui</router-link>
			<router-link to="/threejs-journey-7">threejs journey #7 : les textures</router-link>
			<router-link to="/threejs-journey-8">threejs journey #8 : les materials</router-link>
			<router-link to="/threejs-journey-9">threejs journey #9 : les textes 3d</router-link>
			<router-link to="/threejs-journey-10">threejs journey #10 : les lights</router-link>
			<router-link to="/threejs-journey-11">threejs journey #11 : les shadows</router-link>
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
