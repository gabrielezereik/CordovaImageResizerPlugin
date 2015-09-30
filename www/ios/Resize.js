var exec = require('cordova/exec');
function Resize() {
    this._callback;
    console.log("CoolPlugin.js: is created");
}
Resize.prototype.resize = function(config, callback) {
    this._callback = callback;
    exec(null, null,"Resize", "resize",[config]);
}
Resize.prototype.getNewImagePath = function (path){
  if (this._callback)
        this._callback(null, path);
        alert(path);
}
var Resize = new Resize();

module.exports = Resize;


if (!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.Resize) {
    window.plugins.Resize = Resize;
}