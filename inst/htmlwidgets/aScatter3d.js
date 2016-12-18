HTMLWidgets.widget({

  name: 'aScatter3d',

  type: 'output',

  factory: function(el, width, height) {

    var colliders = null;
    var parentSet = false;

    return {
      renderValue: function(x) {
        // OK to overwite whole data object because all properties updated
        el.setAttribute('plot-area', {
          points: x.points,
          xname: x.xname,
          xlabels: x.xlabels,
          xbreaks: x.xbreaks,
          yname: x.yname,
          ylabels: x.ylabels,
          ybreaks: x.ybreaks,
          zname: x.zname,
          zlabels: x.zlabels,
          zbreaks: x.zbreaks
        });
        mappingUpdate = function(evt) {
          var dataCol = evt.detail.dropped.components["data-frame-column"],
              axis = evt.detail.on.axis;
          // send message only when a data column is dropped on an axis receiver
          if(dataCol && axis) {
            message = {
              plot: el.id,
              variable: dataCol.data.name,
              mapping: axis
            };
            Shiny.onInputChange("mappings", message);
          }
        };
        el.parentEl.addEventListener('dropped', mappingUpdate);
      }
    };
  }
});

/*Shiny.addCustomMessageHandler('updateChart', function(message){
  chartEl = document.getElementById(message.id);

});*/
