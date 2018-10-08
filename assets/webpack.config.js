const webpack = require('webpack');
const path = require('path');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

const env = process.env.NODE_BUILD_MODE;
const SRC_DIR = path.resolve(__dirname, 'js');


const config = {
  mode: env || 'development',

  devtool: 'cheap-module-source-map',

  entry: {
    app: SRC_DIR + '/app.js'
  },

  output: {
    path: path.resolve(__dirname, '../priv/static/js'),
    filename: 'bundle.js'
  },

  module: {
    rules: [
      {
        test: /\.jsx?$/,
        loader: 'babel-loader',
        include: SRC_DIR
      },
      {
        test: /\.(jpg|png|svg|gif|eot|woff|woff2|ttf)$/,
        loader: 'file-loader',
        options: {
          name: path.resolve(__dirname, '../priv/static/img/[name].[ext]')
          // outputPath: 'images/'
        }
      }
      // {
      //   test: /\.less$/,
      //   use: [
      //     MiniCssExtractPlugin.loader,
      //     'css-loader',
      //     { loader: 'less-loader', options: { javascriptEnabled: true } }
      //   ]
      // }
    ]
  },

  resolve: {
    extensions: ['.js', '.jsx', '.json']
  },

  plugins: [
    new MiniCssExtractPlugin({
      // Options similar to the same options in webpackOptions.output
      // both options are optional
      filename: 'css/style.css'
    }),
    new webpack.optimize.ModuleConcatenationPlugin()
  ]
};

module.exports = config;




// module.exports = {
//   entry: './js/app.js',
//   output: {
//     filename: 'app.js',
//     path: path.resolve(__dirname, '../priv/static/js')
//   }
// };
