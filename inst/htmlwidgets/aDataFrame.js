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
        el.components["data-frame"].updateData(x);

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
