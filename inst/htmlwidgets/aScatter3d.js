HTMLWidgets.widget({

  name: 'aScatter3d',

  type: 'output',

  factory: function(el, width, height) {

    var emptyMessage = {
      points: [],
      xname: '',
      xlabels: [],
      xbreaks: [],
      yname: '',
      ylabels: [],
      ybreaks: [],
      zname: '',
      zlabels: [],
      zbreaks: [],
      colorname: '',
      colorbreaks: [],
      colorlabels: [],
      shapename: '',
      shapebreaks: [],
      shapelabels: [],
      sizename: '',
      sizebreaks: [],
      sizelabels: []
    };

    return {
      renderValue: function(dat) {
        var msg = AFRAME.utils.extend({}, emptyMessage);
        if(dat !== 'empty') {
          AFRAME.utils.extend(msg, {
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
        }
        if(dat.colour) {
          msg.colorname = dat.colour.name;
          msg.colorbreaks = dat.colour.breaks;
          msg.colorlabels = dat.colour.labels;
        }
        if(dat.shape) {
          msg.shapename = dat.shape.name;
          msg.shapebreaks = dat.shape.breaks;
          msg.shapelabels = dat.shape.labels;
        }
        if(dat.size) {
          msg.sizename = dat.size.name;
          msg.sizebreaks = dat.size.breaks;
          msg.sizelabels = dat.size.labels;
        }
        // is this why mappings sometimes persist when data source is changed?
        // gh #4
        el.setAttribute('plot', msg);
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

