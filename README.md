# CordovaImageResizerPlugin
Cordova plugin to resize images.

# Installation

```
cd your_cordova_based_plugin
cordova plugin add https://github.com/gabrielezereik/CordovaImageResizerPlugin
```

# Usage
In order to resize an image, all you have to do is to call this function:

```
 window.plugins.Resize.resize(options, function(err, uri) {});
 ```
 
# Options
The options object is structured as follows: 

```
{
"uri": {"type": "string"},
"maxDim": {"type": "int"}
}
```
