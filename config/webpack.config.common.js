const HtmlWebpackPlugin = require('html-webpack-plugin');


const commonConfig = {
  resolve: {
    extensions: ['', '.js', '.jsx', '.elm']
  },
  module: {
    loaders: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/, /Stylesheets.elm/],
        loader: 'elm-webpack?verbose=true&warn=true&debug=false'
      },
      { test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "url-loader?limit=10000&minetype=application/font-woff" },
      { test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "file-loader" }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: 'src/index.html',
      inject: 'body',
      filename: 'index.html'
    }),
  ],
};

module.exports = commonConfig;
