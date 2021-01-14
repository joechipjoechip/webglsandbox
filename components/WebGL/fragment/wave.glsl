#ifdef GL_OES_standard_derivatives
#extension GL_OES_standard_derivatives : enable
#endif

precision mediump float;
varying vec2 vUv;

void main() {
  gl_FragColor = vec4(0., 0., 0., 1.);
}