const path = require('path');
const _ = require('lodash');
const webpack = require('webpack');

const commonConfig = require('./webpack.config.common');

const testConfig = {
  devtool: 'inline-source-map',
  entry: [
    'font-awesome-webpack!./config/font-awesome.config.development.js',
    './src/js/index',
    './src/styles/reset.scss',
    './src/styles/main.scss',
  ],
  output: {
    path: path.join(__dirname, '../.tmp'),
    filename: 'bundle.js',
    publicPath: '/',
  },
  externals: {
    cheerio: 'window',
    'react/addons': true,
    'react/lib/ExecutionEnvironment': true,
    'react/lib/ReactContext': true,
  },
};


const config = _.merge(commonConfig, testConfig);

config.module.loaders = config.module.loaders.concat([
  {
    test: /\.jsx?$/,
    loader: 'babel',
    include: path.join(__dirname, '../src'),
    query: {
      cacheDirectory: true,
    },
  },
  {
    test: /src\/Stylesheets\.elm$/,
    loader: 'style-loader!css-loader!elm-css-webpack',
  },
  {
    test: /\.css$/,
    loader: 'style-loader!css-loader',
    include: /node_modules/,
  },
  {
    test: /\.css$/,
    loader: 'style-loader!css-loader?modules&importLoaders=1&localIdentName=[name]__[local]___[hash:base64:5]',
    exclude: /node_modules/,
  },
  {
    test: /\.scss$/,
    loader: 'style-loader!css-loader?modules&importLoaders=1&localIdentName=[name]__[local]___[hash:base64:5]!sass-loader',
    exclude: /(node_modules|date-picker-theming)/,
  },
  {
    test: /\.scss$/,
    loader: 'style-loader!css-loader!sass-loader',
    include: /(node_modules|date-picker-theming)/,
  },
]);


module.exports = config;
