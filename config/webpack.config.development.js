const path = require('path');
const _ = require('lodash');
const webpack = require('webpack');
const CleanWebpackPlugin = require('clean-webpack-plugin');

const commonConfig = require('./webpack.config.common');

const devConfig = {
  devtool: 'source-maps',
  entry: [
    'webpack-dev-server/client?http://localhost:3000',
    'webpack/hot/only-dev-server',
    'font-awesome-webpack!./config/font-awesome.config.development.js',
    './src/app',
    './src/styles/reset.scss',
    './src/styles/main.scss',
    './src/Stylesheets.elm',
  ],
  output: {
    path: path.join(__dirname, '../.tmp'),
    filename: 'bundle.js',
    publicPath: '/',
  },
  externals: {},
  devServer: {
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        secure: false
      }
    }
  }
};


const config = _.merge(commonConfig, devConfig);

config.module.loaders = config.module.loaders.concat([
  {
    test: /\.jsx?$/,
    loader: 'babel',
    include: path.join(__dirname, '../src'),
    query: {
      cacheDirectory: true,
    }
  },
  {
    test: /src\/Stylesheets\.elm$/,
    loader: 'style-loader!css-loader!elm-css-webpack',
    include: path.join(__dirname, '../src'),
  },
  {
    test: /\.css$/,
    loader: 'style-loader!css-loader',
    include: /node_modules/,
  },
  {
    test: /\.css$/,
    loader: 'style-loader!css-loader',
    exclude: /node_modules/,
  },
  {
    test: /\.scss$/,
    loader: 'style-loader!css-loader!sass-loader',
    exclude: /node_modules/,
  },
  {
    test: /\.scss$/,
    loader: 'style-loader!css-loader!sass-loader',
    include: /node_modules/,
  },
]);

config.plugins = config.plugins.concat([
  new CleanWebpackPlugin(['./.tmp'], {
    root: path.join(__dirname, '../'),
  }),
]);

module.exports = config;
