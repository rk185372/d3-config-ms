#!/bin/sh
 
cd ../MobileAuthAPITransformer
npx webpack --config webpack.config.js
cp dist/APITransformer.js ../d3-next-ios/D3Pods/APITransformer/APITransformer/Assets/APITransformer.js