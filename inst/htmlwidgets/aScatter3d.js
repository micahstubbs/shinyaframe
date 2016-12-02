HTMLWidgets.widget({

  name: 'aScatter3d',

  type: 'output',

  factory: function(el, width, height) {

    var colliders = null;
    var parentSet = false;

    return {


      renderValue: function(x) {

        // if new, update colliders
        if(colliders === null) {
          colliders = document.querySelectorAll("a-entity[hand-controls]");
          colliders.forEach(function(item) {
            item.components["aabb-collider"].update();
          });
        }
        if(!parentSet) {
          el.setAttribute("mixin", x.parentTheme);
          parentSet = true;
        }

        var mark = null;
        register_mark = function(coord, geom, mat) {
          mark = document.createElement("a-entity");
          mark.setAttribute("position", coord);
          mark.setAttribute("geometry", geom);
          mark.setAttribute("material", mat);
          el.appendChild(mark);
        };

        if(Array.isArray(x.coords)) {
          for(i = 0; i < x.coords.length; i++) {
            register_mark(
              x.coords[i],
              Array.isArray(x.geometry) ? x.geometry[i] : x.geometry,
              Array.isArray(x.material) ? x.material[i] : x.material
            );
          }
        } else {
          register_mark(x.coords, x.geometry, x.material);
        }


      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
