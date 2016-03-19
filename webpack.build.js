var webpack = require('webpack');
module.exports = {
  entry: "./front/application.js",
  output: {
    path: "./lib/pig-media-server/views/",
    filename: "bundle.js"
  },
  module: {
    loaders: [
      {
        test: /\.css$/, 
        loader: "style!css"
      },
      {
        test: /.js?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        query: {
          presets: ['es2016-node5', 'react', 'es2015']
        }
      }
    ]
  },
  plugins: [new webpack.optimize.UglifyJsPlugin()]
};
