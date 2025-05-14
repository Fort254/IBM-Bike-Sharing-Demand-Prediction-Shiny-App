# Load required libraries
require(leaflet)  # Loads the leaflet package, used to create interactive maps

# Create a RShiny UI
shinyUI(
  fluidPage(padding = 5,  # Defines the layout of the page with 5px padding
            titlePanel("Bike-sharing demand prediction app"),  # Adds a title at the top of the app
            
            sidebarLayout(  # Defines a layout with a sidebar and a main panel
              
              mainPanel(  # This is the main area of the app (on the right side typically)
                leafletOutput("city_bike_map", height = "300px", width = "100%")  
                # Displays an interactive map that will show bike-sharing data
              ),
              
              sidebarPanel(  # Sidebar area for controls and plots (usually on the left)
                
                selectInput(inputId = "city_dropdown",  # Drop down menu input for selecting a city
                            label = "Select a City",
                            choices = c("All", "Seoul", "Suzhou", "London", "New York", "Paris"),
                            selected = "All"),  # Default selected city is "All"
                
                plotOutput("temp_line", height = "300px", width = "100%"),  
                # Placeholder for a temperature trend plot
                
                plotOutput("bike_line", height = "300px", width = "100%", click = "plot_click"),  
                # Plot showing bike usage trends; allows clicking for interactivity
                
                verbatimTextOutput("bike_date_output"),  
                # Displays text output, showing details of the clicked date
                
                plotOutput("humidity_pred_chart", height = "300px", width = "100%")  
                # Plot that shows predicted demand based on humidity
              )
            )
  )
)
