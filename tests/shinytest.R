library(shiny)
library(shinyaframe)

runApp(list(
  ui = bootstrapPage(
    actionButton("update","update gauge"),

    # example use of the automatically generated output function
    atags$scene(
      atags$assets(
        atags$mixin(id = "point", class = "point",
                          geometry = "primitive: sphere; radius: 0.1",
                          material = "color: yellow;")
      ),
      aScatter3dOutput("mywidg")
    )
  ),
  server = function(input, output) {

    # reactive that generates a random value for the gauge
    value = reactive({
      input$update
      round(runif(1,0,100),2)
    })

    # example use of the automatically generated render function
    output$mywidg <- renderAScatter3d({
      # C3Gauge widget
      aScatter3d(list(parentTheme = "daddy",
                      x = 1:3, y = 1:3, z = 3:1))
    })
  }
))
