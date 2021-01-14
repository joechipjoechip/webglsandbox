<template>
	<div class="index-container">
		<nav>
			<router-link to="/torus">torus</router-link>
			<router-link to="/kinetic">kinetic</router-link>
			<router-link to="/wave-motion">wave-motion</router-link>
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
		display: block;
		width: 80%;
		margin: 0 auto;
		text-align: center;

		& > * {
			text-transform: capitalize;
			margin-left: 40px;

			&:first-of-type {
				margin-left: 0;
			}
		}
	}

</style>
