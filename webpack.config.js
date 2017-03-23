var webpack = require('webpack')

module.exports = {
  entry: [
    'webpack-hot-middleware/client',
    './entry.js'
  ],

  devtool: 'source-map',

  output: {
    path: __dirname,
    pathinfo: true,
    filename: 'bundle.js'
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        use: ["source-map-loader"],
        enforce: "pre"
      }
    ]
  },

  plugins: [
    // new webpack.HotModuleReplacementPlugin(),
    // enable HMR globally
    // OccurenceOrderPlugin is needed for webpack 1.x only 
    new webpack.HotModuleReplacementPlugin(),

    new webpack.NamedModulesPlugin(),
    // prints more readable module names in the browser console on HMR updates
  ]
};
