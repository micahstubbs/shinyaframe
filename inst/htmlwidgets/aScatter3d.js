HTMLWidgets.widget({

  name: 'aScatter3d',

  type: 'output',

  factory: function(el, width, height) {

    var colliders = null;
    var parentSet = false;

    return {
      renderValue: function(dat) {
        // OK to overwite whole data object because all properties updated
        el.setAttribute('plot-area', {
          points: dat.points,
          xname: dat.x.name,
          xlabels: dat.x.labels,
          xbreaks: dat.x.breaks,
          yname: dat.y.name,
          ylabels: dat.y.labels,
          ybreaks: dat.y.breaks,
          zname: dat.z.name,
          zlabels: dat.z.labels,
          zbreaks: dat.z.breaks
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
