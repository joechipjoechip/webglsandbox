import * as THREE from "three";

import { OrbitControls } from "three/examples/jsm/controls/OrbitControls";

import vertexShader from "./vertex/wave.glsl";

import fragmentShader from "./fragment/wave.glsl";



class Wave {
	constructor(myCanvas, imgPath) {

		this.imgPath = imgPath;

		console.log("hey : ", this.imgPath);

		this.scene = new THREE.Scene();

		this.camera = new THREE.PerspectiveCamera(
			45,
			window.innerWidth / window.innerHeight,
			0.1,
			100
		);

		this.camera.position.z = 1;

		this.renderer = new THREE.WebGLRenderer({
			canvas: myCanvas,
			antialias: true
		});

		this.renderer.setSize(window.innerWidth, window.innerHeight);

		this.renderer.setClearColor(0xffffff, 1);

		this.clock = new THREE.Clock();

		this.controls = new OrbitControls(this.camera, this.renderer.domElement);

		this.controls.enableZoom = false;

		// Vertical
		// Range is 0 to Math.PI radians.
		// https://up2school.com/fr/article/mathematiques/le-cercle-trigonometrique/
		this.controls.minPolarAngle = Math.PI / 3;
		this.controls.maxPolarAngle = (2 * Math.PI) / 3;

		// Horizontal
		// If set, must be a sub-interval of the interval [ - Math.PI, Math.PI ].
		this.controls.minAzimuthAngle = Math.PI / - 5;
		this.controls.maxAzimuthAngle = Math.PI / 5;

		this.onResize();

	}

	init() {
		this.createMesh();
		this.addEvents();
	}

	createMesh() {
		this.geometry = new THREE.PlaneGeometry(0.4, 0.6, 16, 16);

		this.material = new THREE.ShaderMaterial({
			vertexShader,
			fragmentShader,
			uniforms: {
				uTime: { value: 0.0 },
				uTexture: { value: new THREE.TextureLoader().load(this.imgPath) },
			},
			// wireframe: true,
			side: THREE.DoubleSide
		});

		// this.material = new THREE.ShaderMaterial({
		// 	vertexShader,
		// 	fragmentShader,
		// 	uniforms: {
		// 	  uTime: { value: 0.0 },
		// 	  uTexture: { value: new THREE.TextureLoader().load(img) },
		// 	},
		//   });

		this.mesh = new THREE.Mesh(this.geometry, this.material);

		this.scene.add(this.mesh);

	}

	addEvents() {

		window.requestAnimationFrame(this.run.bind(this));

		window.addEventListener("resize", this.onResize.bind(this), false);

	}

	run() {
		requestAnimationFrame(this.run.bind(this));
		this.render();
	}

	render() {
		this.material.uniforms.uTime.value = this.clock.getElapsedTime();
		this.renderer.render(this.scene, this.camera);
	}

	onResize() {
		const w = window.innerWidth;
		const h = window.innerHeight;

		this.camera.aspect = w / h;
		this.camera.updateProjectionMatrix();

		this.renderer.setSize(w, h);
	}
}

export default Wave;
