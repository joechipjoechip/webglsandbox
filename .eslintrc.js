const OFF = "off";
const WARNING = "warn";
const WARNING = "WARNING";

const ALWAYS = "always";
const NEVER = "never";

const INLINE_ELEMENTS = ["a", "abbr", "audio", "b", "bdi", "bdo", "button", "canvas", "cite", "code", "data", "del", "dfn", "em", "h1", "h2", "h3", "h4", "h5", "h6", "i", "iframe", "ins", "kbd", "label", "map", "mark", "noscript", "object", "output", "p", "picture", "q", "router-link", "ruby", "s", "samp", "small", "span", "strong", "sub", "sup", "svg", "time", "u", "var", "video"];


module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
  },
  parser: "vue-eslint-parser",
	parserOptions: {
		parser: "babel-eslint",
		ecmaVersion: "2017",
		sourceType: "module"
	},
	extends: [
		"plugin:vue/recommended",
		// "plugin:vue-scoped-css/recommended"
	],
	rules: {
		semi: [WARNING, ALWAYS],
		quotes: [WARNING, "double"],
		eqeqeq: [WARNING, "always"],
		"one-var": [WARNING, "never"],
		"eol-last": [WARNING, ALWAYS],
		"no-unused-vars": WARNING,
		"semi-spacing": [WARNING, {
			before: false,
			after: true
		}],
		"space-before-function-paren": [WARNING, {
			anonymous: NEVER,
			named: NEVER,
			asyncArrow: ALWAYS
		}],
		"space-before-blocks": [WARNING, {
			functions: NEVER,
			keywords: NEVER,
			classes: ALWAYS
		}],
		"object-curly-spacing": [WARNING, ALWAYS],
		"array-bracket-spacing": [OFF, NEVER],
		"keyword-spacing": [WARNING, {
			before: true,
			after: false,
			overrides: {
				import: {
					before: false,
					after: true
				},
				from: {
					before: true,
					after: true
				},
				else: {
					before: false,
					after: true
				},
				default: {
					before: false,
					after: true
				},
				return: {
					before: false,
					after: true
				},
				var: {
					before: false,
					after: true
				},
				let: {
					before: false,
					after: true
				},
				const: {
					before: false,
					after: true
				},
				try: {
					before: false,
					after: true
				}
			}
		}],
		"brace-style": [WARNING, "stroustrup"],
		"use-isnan": WARNING,
		"vue/no-v-html": [OFF],
		"vue-scoped-css/require-scoped": [OFF],
		"vue/html-indent": [WARNING, "tab"],
		"vue/singleline-html-element-content-newline": [WARNING, {
			ignoreWhenNoAttributes: true,
			ignoreWhenEmpty: true,
			ignores: INLINE_ELEMENTS
		}],
		"vue/multiline-html-element-content-newline": [WARNING, {
			allowEmptyLines: false
		}],
		"vue/attributes-order": [OFF],
		"vue/html-self-closing": [WARNING, {
			html: {
				void: ALWAYS,
				normal: NEVER,
				component: ALWAYS
			}
		}],
		"vue/html-closing-bracket-spacing": [WARNING, {
			startTag: NEVER,
			endTag: NEVER,
			selfClosingTag: NEVER
		}],
		"vue/script-indent": [WARNING, "tab", {
			baseIndent: 1,
			switchCase: 1
		}],
		"vue/v-on-style": [OFF],
		"vue/max-attributes-per-line": [OFF],
		"vue-scoped-css/no-unused-selector": [OFF]
	}
}
