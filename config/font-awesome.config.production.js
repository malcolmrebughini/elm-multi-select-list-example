module.exports = {
  styleLoader: require('extract-text-webpack-plugin').extract('style-loader', 'css-loader!less-loader'),
  styles: {
    core: true,
    icons: true,
    larger: true,
    path: true,
    animated: true,
    mixins: true,
    'rotated-flipped': true,
    stacked: true,
  },
};
