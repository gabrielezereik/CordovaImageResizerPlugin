var exec = require('cordova/exec');
function Resize() {
    console.log("CoolPlugin.js: is created");
}
Resize.prototype.resize = function(config, callback) {
    exec(function(result){
        //alert("OK" + result);
        callback(null,result);
    }, function(result){
        //console.log(result);
        //alert("Error" + result);
        callback(result);
    },"Resize", "",[config]);
}

var Resize = new Resize();

module.exports = Resize;
if (!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.Resize) {
    window.plugins.Resize = Resize;
}