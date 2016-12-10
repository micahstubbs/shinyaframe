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
        mappingUpdate = function(evt) {
          message = {
            plot: el.id,
            variable: evt.detail.dropped.components["data-frame-column"].data.name,
            mapping: evt.detail.on.axis
          };
          Shiny.onInputChange("mappings", message);
        };
        el.parentEl.addEventListener('dropped', mappingUpdate);
      }
    };
  }
});

Shiny.addCustomMessageHandler('updateChart', function(message){
  chartEl = document.getElementById(message.id);

});
