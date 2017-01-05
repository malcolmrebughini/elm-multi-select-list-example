const path = require('path');
const _ = require('lodash');
const webpack = require('webpack');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const ExtractTextPlugin = require("extract-text-webpack-plugin");

const commonConfig = require('./webpack.config.common');

const prodConfig = {
  entry: [
    './src/app',
    'font-awesome-webpack!./config/font-awesome.config.production.js',
    './src/styles/reset.scss',
    './src/styles/main.scss',
    './src/Stylesheets.elm',
  ],
  output: {
    path: path.join(__dirname, '../www'),
    filename: 'bundle.js',
    publicPath: '/'
  },
};

const config = _.merge(commonConfig, prodConfig);

config.module.loaders = config.module.loaders.concat([
  {
    test: /\.jsx?$/,
    loader: 'babel',
    exclude: [/node_modules/],
    include: path.join(__dirname, '../src'),
  },
  {
    test: /src\/Stylesheets\.elm$/,
    loader: ExtractTextPlugin.extract('style-loader', 'css-loader', 'elm-css-webpack'),
    // include: path.join(__dirname, '../src'),
  },
  {
    test: /\.css$/,
    loader: ExtractTextPlugin.extract('style-loader', 'css-loader'),
    include: /node_modules/,
  },
  {
    test: /\.css$/,
    loader: ExtractTextPlugin.extract('style-loader', 'css-loader'),
    exclude: /node_modules/,
  },
  {
    test: /\.scss$/,
    loader: ExtractTextPlugin.extract('style-loader', 'css-loader!sass-loader'),
    include: /node_modules/,
  },
  {
    test: /\.scss$/,
    loader: ExtractTextPlugin.extract('style-loader', 'css-loader!sass-loader'),
    exclude: /node_modules/,
  },
]);

config.plugins = config.plugins.concat([
  new CleanWebpackPlugin(['./www'], {
    root: path.join(__dirname, '../'),
  }),
  new webpack.DefinePlugin({
    'process.env': {
      'NODE_ENV': JSON.stringify('production')
    }
  }),
  new webpack.optimize.OccurenceOrderPlugin(),
  new webpack.optimize.UglifyJsPlugin({
    minimize: true,
    compressor: true,
  }),
  new ExtractTextPlugin("css/styles.css", { allChunks: true }),
]);

module.exports = config;
