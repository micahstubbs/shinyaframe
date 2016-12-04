HTMLWidgets.widget({

  name: 'aDataFrame',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance
    var setup = false;


    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
        if(setup !== true) {
          el.setAttribute("data-frame", "");
          setup = true;
        }
        function addcol(y) {
          var col = document.createElement("a-entity");
          col.setAttribute("data-frame-column", y);

           // "data: ".concat(JSON.stringify(y.coldat),
            //"; name: ", y.name, "; type: ", y.type));
          el.appendChild(col);
        }

        if(Array.isArray(x)) {
          x.forEach(addcol);
        } else {
          addcol(x);
        }
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
