HTMLWidgets.widget({

  name: 'aScatter3d',

  type: 'output',

  factory: function(el, width, height) {

    var colliders = null;
    var parentSet = false;

    return {
      renderValue: function(x) {
        ////////////////////TODO////////////////
        // change attribute update to avoid overwriting other settings
        el.setAttribute('plot-area', {
          points: x.points,
          xlabels: x.xlabels,
          xbreaks: x.xbreaks,
          ylabels: x.ylabels,
          ybreaks: x.ybreaks,
          zlabels: x.zlabels,
          zbreaks: x.zbreaks
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

/*Shiny.addCustomMessageHandler('updateChart', function(message){
  chartEl = document.getElementById(message.id);

});*/
