
// const path = require('path');
const { DefinePlugin } = require('webpack');
const { defineConfig } = require('@vue/cli-service');

module.exports = defineConfig({
  transpileDependencies: true,
  lintOnSave: false,
  configureWebpack: {
    optimization: {
      splitChunks: {
        chunks: 'all',
      },

    },
    plugins: [
      new DefinePlugin({
        '__VUE_PROD_HYDRATION_MISMATCH_DETAILS__': JSON.stringify(false)
      })
    ],
  },
  devServer: {
    https: true, // 启用 HTTPS
  },
  chainWebpack: config => {
    config.module
      .rule('vue')
      .use('vue-loader')
      .tap(options => {
        options.compilerOptions = {
          isCustomElement: tag => tag === 'w3m-button'
        };
        return options;
      });
  },
});




// const { defineConfig } = require('@vue/cli-service');
// const fs = require('fs');
// const path = require('path');
// import vue from '@vitejs/plugin-vue';

// module.exports = defineConfig({
//   plugins: [vue({
//     template: {
//       compilerOptions: {
//         // 定义特性标志
//         isCustomElement: (tag) => tag === 'w3m-button'
//       }
//     }
//   })],
//   define: {
//     '__VUE_PROD_HYDRATION_MISMATCH_DETAILS__': false
//   },
//   devServer: {
//     https: true,// 指定开发服务器运行的端口号
//   },
//   transpileDependencies: true,
//   configureWebpack: {
//     optimization: {
//       splitChunks: {
//         chunks: 'all',
//       },
//     },
//   },
//   css: {
//     extract: true,
//     sourceMap: false,
//     loaderOptions: {
//       css: {
//         // options here will be passed to css-loader
//       },
//       postcss: {
//         // options here will be passed to postcss-loader
//       }
//     }
//   },
//   chainWebpack: config => {
//     config.optimization.splitChunks({
//       chunks: 'all',
//     });

//     config.plugin('html').tap(args => {
//       args[0].minify = {
//         removeComments: true,
//         collapseWhitespace: true,
//         removeAttributeQuotes: true,
//       };
//       return args;
//     });


//   }
// })
