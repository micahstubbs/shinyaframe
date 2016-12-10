HTMLWidgets.widget({

  name: 'aScatter3d',

  type: 'output',

  factory: function(el, width, height) {

    var colliders = null;
    var parentSet = false;

    return {
      renderValue: function(x) {
        el.setAttribute('plot-area', {
          x: x.x,
          y: x.y,
          z: x.z,
          geometry: x.geometry,
          material: x.material
        });
      }
    };
  }
});

Shiny.addCustomMessageHandler('updateChart', function(message){
  chartEl = document.getElementById(message.id);

});
