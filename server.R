library(shiny)       # For building interactive web apps
library(ggplot2)     # For plotting data
library(leaflet)     # For rendering interactive maps
library(tidyverse)   # Collection of packages for data manipulation and visualization
library(httr)        # For working with web APIs (likely used in your `model_prediction.R`)
library(scales)      # For controlling axis formatting in plots

source("model_prediction.R")  # Loads external R script that includes functions like `generate_city_weather_bike_data`

# Function to test data generation - useful during development
test_weather_data_generation <- function() {
  city_weather_bike_df <- generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df) > 0)  # Checks that data was returned
  print(head(city_weather_bike_df))            # Prints first few rows for inspection
  return(city_weather_bike_df)
}

# Define server logic for the Shiny app
shinyServer(function(input, output) {
  
  # Generate dataset of weather and bike predictions
  city_weather_bike_df <- generate_city_weather_bike_data()
  
  # Summarize max bike predictions per city for map visualization
  cities_max_bike <- city_weather_bike_df %>%
    group_by(CITY_ASCII, LAT, LNG, LABEL, BIKE_PREDICTION_LEVEL, DETAILED_LABEL) %>%
    summarise(MAX_BIKE_PREDICTION = max(BIKE_PREDICTION), .groups = 'drop')
  
  # Define color scheme for prediction levels
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))
  
  # React when the user selects a city
  observeEvent(input$city_dropdown, {
    
    if (input$city_dropdown == "All") {
      # If 'All' is selected, show all cities on the map using circle markers
      output$city_bike_map <- renderLeaflet({
        leaflet(data = cities_max_bike) %>%
          addTiles() %>%
          addCircleMarkers(lng= ~ LNG, lat =  ~ LAT, 
                           radius = ~case_when(  # Adjust marker size based on prediction level
                             BIKE_PREDICTION_LEVEL == "small" ~ 6,
                             BIKE_PREDICTION_LEVEL == "medium" ~ 10,
                             BIKE_PREDICTION_LEVEL == "large" ~ 12
                           ),
                           color = ~color_levels(BIKE_PREDICTION_LEVEL),  # Color by level
                           popup = ~LABEL)  # Show popup with city label
      })
      
    } else {
      # If a specific city is selected
      selected_city <- input$city_dropdown
      selected_data <- city_weather_bike_df %>% 
        filter(CITY_ASCII == selected_city)  # Filter data for selected city
      
      # Render marker map for selected city
      output$city_bike_map <- renderLeaflet({
        leaflet(data = selected_data) %>%
          addTiles() %>%
          addMarkers(lng = ~LNG, lat = ~ LAT, popup = ~DETAILED_LABEL)  # Use detailed label in popup
      })
      
      # Temperature trend plot over time
      output$temp_line <- renderPlot({
        ggplot(selected_data, aes(x = as.POSIXct(FORECASTDATETIME), y = TEMPERATURE)) +
          geom_line(color = "mintcream", size = 1.2) +
          geom_point(color = "orange", size = 2) +
          geom_text(aes(label = round(TEMPERATURE, 1)), vjust = -0.5, size = 3) +
          scale_x_datetime(
            name = "Time (3 hours ahead)",
            breaks = scales::date_breaks("10 hours"),
            labels = scales::date_format("%H:%M")
          ) +
          ylab("Temperature") +
          ggtitle(paste("5-day Temperature Trend for", selected_city)) +
          theme_minimal()
      })
      
      # Bike-sharing prediction plot over time
      output$bike_line <- renderPlot({
        ggplot(selected_data, aes(x = as.POSIXct(FORECASTDATETIME), y = BIKE_PREDICTION)) +
          geom_line(color = "plum", linetype = "dashed", size = 1.2) +
          geom_point(color = "red4", size = 2) +
          geom_text(aes(label = round(BIKE_PREDICTION, 1)), vjust = -0.5, size = 3) +
          scale_x_datetime(
            name = "Time (3 hours ahead)",
            breaks = scales::date_breaks("1 day"),
            labels = scales::date_format("%b %d")
          ) +
          ylab("Bike-Sharing Demand Prediction") +
          ggtitle(paste("Bike-Sharing Prediction Trend for", selected_city)) +
          theme_minimal()
      })
      
      # Show prediction details based on user clicking the plot
      output$bike_date_output <- renderPrint({
        click <- input$plot_click
        if (is.null(click)) return("Click on a point to see details")  # Default message
        
        # Find the nearest time point to the x-axis click
        nearest_point <- selected_data[which.min(abs(as.numeric(as.POSIXct(selected_data$FORECASTDATETIME)) - as.numeric(click$x))), ]
        
        # Show datetime and prediction
        paste0("DateTime: ", nearest_point$FORECASTDATETIME,
               " Bike Prediction: ", nearest_point$BIKE_PREDICTION)
      })
      
      # Humidity vs bike demand prediction plot with a polynomial fit
      output$humidity_pred_chart <- renderPlot({
        ggplot(selected_data, aes(x = HUMIDITY, y = BIKE_PREDICTION)) +
          geom_point(color = "tan", size = 2, alpha = 0.7) +
          geom_smooth(method = "lm", formula = y ~ poly(x, 4), se = FALSE, 
                      color = "salmon", linetype = "solid") +
          xlab("Humidity") +
          ylab("Bike-Sharing Prediction") +
          ggtitle(paste("Humidity vs. Bike-Sharing Prediction in ", selected_city)) +
          theme_minimal()
      })
    }
  })
})
