# Shiny App: Interactive Bike Sharing Demand Dashboard

This Shiny application provides an interactive interface for exploring bike sharing demand in Seoul. It visualizes weather factors, seasonal trends, rental activity patterns, and model predictions derived from a robust data pipeline and regression modeling in R.

---

## Features

-  **Temporal Exploration**: Filter data by date and hour.
-  **Weather Impact**: Analyze how temperature, humidity, and wind affect bike demand.
-  **Seasonal Trends**: Explore demand trends across Spring, Summer, Autumn, and Winter.
-  **Model Insights**: Visualize model coefficients and compare predictive performance.
-  **Dynamic Plots**: Interactive scatter plots, boxplots, histograms, and time series.

##  Requirements

Ensure the following R packages are installed:

  "shiny", "tidyverse", "lubridate", "ggplot2", 
  "plotly", "DT", "shinydashboard", "leaflet"

##  Run the App Locally

library(shiny)
runApp("path/to/shiny_app")

## Example Visualizations

- Scatter plot of `RENTED_BIKE_COUNT` vs. `TEMPERATURE`, colored by hour.
- Time series plot of bike rentals over time.
- Model coefficient bar plots showing variable importance.

## Dataset Summary

The app uses the processed and normalized dataset `seoul_bike_sharing_converted_normalized.csv`, which contains:

- **Date & Hour** (categorical)
- **Normalized features**: `TEMPERATURE`, `HUMIDITY`, `WIND_SPEED`, `VISIBILITY`, etc.
- **Categorical indicators**: `SEASONS`, `HOLIDAY`, `FUNCTIONING_DAY`, `HOUR`
- **Target**: `RENTED_BIKE_COUNT`

## 👤 Author

**Fortunatus Ochieng**  
Data Scientist | Passionate about data-driven decision making  

