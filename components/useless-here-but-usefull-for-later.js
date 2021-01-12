const pkg = require('./package');
let baseUrlJson;
let overrideCors = false;
const BUILD_URL = '/themes/custom/vue-app';
const buildUrl = process.env.NODE_ENV === 'production' ? BUILD_URL : '';
module.exports = {
    // activate vue devtools in production (bad for performances, use with care)
    vue: {
        config: process.env.DEBUG ? {
        devtools: true
        } : {}
    },
    // sourceMap: true,
    env: {
        buildUrl,
    },
    mode: 'spa',
    /*
    ** Headers of the page
    */
    head: {
        title: 'Water Sources',
        meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        // { hid: 'description', name: 'description', content: pkg.description }
        ],
        link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon-water-cycle.png' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon-water-cycle.png' },
        { rel: 'preload', as: 'font', crossorigin: 'crossorigin', type: 'font/woff', href: '/themes/custom/vue-app/assets/fonts/cd9e7be.woff'}, // preload font after hash
        { rel: 'preload', as: 'font', crossorigin: 'crossorigin', type: 'font/woff', href: '/themes/custom/vue-app/assets/fonts/8253a72.woff'} // preload font after hash
        ]
    },
    /*
    ** Customize the progress-bar color
    */
    loading: { color: '#fff' },
    /*
    ** Global CSS
    */
    css: [
    ],
    /*
    ** Plugins to load before mounting the App
    */
    plugins: [
        { src: '~/plugins/nuxt-client-init.js', ssr: false },
        { src: '~/plugins/localStorage.js', ssr: false },
        { src: '~/plugins/gtm.js', mode: 'client' }
    ],
    polyfill: {
    features: [
    {
    require: 'custom-event-polyfill'
    },
    {
    require: 'core-js/fn/promise'
    },
    {
    detect: () => typeof Array.from !== 'function',
    require: 'core-js/fn/array/from'
    },
    // {
    // detect: () => !String.prototype.includes,
    // require: 'core-js/fn/string/includes'
    // },
    // {
    // detect: () => typeof Array.prototype.includes !== 'function',
    // require: 'core-js/fn/array/includes'
    // },
    {
    detect: () => typeof Symbol !== 'function',
    require: 'core-js/fn/symbol'
    },
    {
    detect: () => typeof Symbol !== 'function',
    require: 'core-js/fn/symbol/iterator'
    },
    {
    require: 'classlist-polyfill'
    },
    {
    require: 'svg-dataset-polyfill'
    },
    // {
    // detect: () => document.documentMode === 11, // detect IE11, could not find a better way for classlist
    // require: 'classlist-polyfill'
    // },
    ]
    },
    /*
    ** Nuxt.js modules
    */
    modules: [
    // Doc: https://github.com/nuxt-community/axios-module#usage
    '@nuxtjs/axios',
    '@nuxtjs/style-resources',
    '@nuxtjs/router',
    'nuxt-polyfill'
    ],
    styleResources: {
    scss: [
    './assets/scss/vars/*.scss',
    './assets/scss/abstracts/_mixins.scss', // use underscore "_" & also file extension ".scss"
    './assets/scss/abstracts/_reset.scss',
    './assets/scss/abstracts/_media.scss',
    './assets/scss/abstracts/_general.scss',
    './assets/scss/abstracts/_fonts.scss'
    ]
    },
    /*
    ** Axios module configuration
    */
    axios: {
    // See https://github.com/nuxt-community/axios-module#options
    },
    /*
    ** Build configuration
    */
    build: {
        transpile: [
            'vue-clamp',
            'resize-detector'
        ],
        /*
        ** You can extend webpack config here
        */
        extend(config, ctx) {
            if (ctx.isClient) {
                if (process.env.DEBUG) {
                    config.devtool = '#source-map';
                }
                config.module.rules.push({
                    test: /\.(fs|vs|glsl)$/,
                    loader: "shader-loader",
                    options: {
                        glsl: {
                            chunkPath: __dirname + "/assets/shaders/chunks"
                        }
                    }
                });
            }
            // Run ESLint on save
            // if (ctx.isDev && ctx.isClient) {
            // config.module.rules.push({
            // enforce: 'pre',
            // test: /\.(js|vue)$/,
            // loader: 'eslint-loader',
            // exclude: /(node_modules)/
            // })
            // }
        },
        publicPath: '/assets',
        quiet: false
    },
    generate: {
    routes: [
    '/'
    ],
    dir: `../project/docroot${BUILD_URL}`
    },
    router: {
    base: buildUrl
    }
}