const path = require('path');

module.exports = {
  mode: "development",

  entry: "./main.ts",

  module: {
    rules: [
      {
        test: /\.ts$/,
        use: "ts-loader"
      }
    ]
  },
  resolve: {
    extensions: [".ts", ".js"]
  },

  devServer: {
    contentBase: path.join(__dirname, 'dist'),
    open: true
  }
}
