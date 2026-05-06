library(shiny)
library(tidyverse)
library(ggplot2)
library(plotly)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)

# =========================
# Load and wrangle data
# =========================
military <- read.csv("military-spending-as-a-share-of-gdp-sipri.csv")

military <- military |>
  rename(
    spendingPCT = `Military.expenditure....of.GDP.`,
    worldRegion = `World.region.according.to.OWID`
  ) |>
  mutate(Year = as.numeric(Year))

military_nonmissing <- military |>
  filter(!is.na(spendingPCT), !is.na(Year), !is.na(Entity))

# Load world map
world <- ne_countries(scale = "medium", returnclass = "sf")

# =========================
# Theme for map
# =========================
my_map_theme <- function() {
  theme_minimal() +
    theme(
      panel.grid = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank()
    )
}

# =========================
# Map function
# =========================
military_map <- function(yr) {
  
  map_data <- military |>
    filter(Year == yr, !is.na(Code), !is.na(spendingPCT)) |>
    select(Entity, Code, spendingPCT) |>
    mutate(spending_cap = pmin(spendingPCT, 9))
  
  world_military <- world |>
    left_join(map_data, by = c("iso_a3" = "Code")) |>
    mutate(
      hover_name = ifelse(is.na(Entity), name, Entity),
      hover_value = ifelse(
        is.na(spendingPCT),
        "NA value",
        paste0(round(spendingPCT, 1), "% of GDP")
      ),
      hover_text = paste0(
        "Country: ", hover_name,
        "<br>Year: ", yr,
        "<br>Military spending: ", hover_value
      )
    )
  
  p <- ggplot(world_military) +
    geom_sf(
      aes(fill = spending_cap, text = hover_text),
      color = "gray35",
      linewidth = 0.15
    ) +
    scale_fill_gradient(
      name = "Military Spending (% of GDP)",
      low = "#fee5d9",
      high = "#a50f15",
      limits = c(0, 9),
      breaks = 0:9,
      labels = c(paste0(0:8, "%"), "9%+"),
      na.value = "gray90",
      guide = guide_colorbar(
        title.position = "top",
        title.hjust = 0.5,
        barwidth = unit(12, "lines")
      )
    ) +
    my_map_theme() +
    labs(
      title = paste("Military Spending as a Share of GDP by Country,", yr),
      subtitle = "Military expenditure shown as a percentage of GDP"
    ) +
    theme(
      plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5),
      legend.position = "bottom"
    )
  
  ggplotly(p, tooltip = "text") |>
    style(hoveron = "fills")
}

# =========================
# Line graph function
# =========================
military_line_plot <- function(yr, top_n = 5) {
  
  rank_df <- military_nonmissing |>
    filter(Year == yr) |>
    arrange(desc(spendingPCT)) |>
    slice(1:top_n)
  
  rank_order <- rank_df$Entity
  
  plot_data <- military_nonmissing |>
    filter(Entity %in% rank_order) |>
    mutate(
      Entity = factor(Entity, levels = rank_order),
      tooltip_text = paste0(
        "Year: ", Year,
        "<br>Country: ", Entity,
        "<br>% of GDP: ", round(spendingPCT, 1), "%"
      )
    )
  
  p <- ggplot(
    plot_data,
    aes(
      x = Year,
      y = spendingPCT,
      color = Entity,
      group = Entity,
      text = tooltip_text
    )
  ) +
    geom_line(linewidth = 0.8) +
    theme_minimal() +
    labs(
      title = "Military Expenditure as a Share of GDP",
      subtitle = paste("Top", top_n, "countries ranked by", yr),
      x = "Year",
      y = "Percentage of GDP (%)",
      color = "Country"
    ) +
    scale_x_continuous(
      breaks = seq(min(military_nonmissing$Year), max(military_nonmissing$Year), by = 10)
    ) +
    scale_y_continuous(
      labels = function(x) paste0(x, "%")
    ) +
    theme(
      plot.title = element_text(face = "bold"),
      legend.position = "none"
    )
  
  ggplotly(p, tooltip = "text") |>
    layout(
      hovermode = "x unified",
      showlegend = FALSE
    )
}

# =========================
# UI
# =========================
ui <- fluidPage(
  
  titlePanel("Military Spending as a Share of GDP"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "yr",
        "Select a year:",
        min = min(military_nonmissing$Year, na.rm = TRUE),
        max = max(military_nonmissing$Year, na.rm = TRUE),
        value = max(military_nonmissing$Year, na.rm = TRUE),
        step = 1,
        sep = "",
        animate = animationOptions(interval = 1200, loop = FALSE)
      ),
      
      conditionalPanel(
        condition = "input.main_tabs == 'line_tab'",
        selectInput(
          "top_n",
          "Number of countries in line graph:",
          choices = c(5, 10, 15),
          selected = 10
        )
      ),
      
      br(),
      helpText("Hover over the graphs for details.")
    ),
    
    mainPanel(
      tabsetPanel(
        id = "main_tabs",
        
        tabPanel(
          title = "Map",
          value = "map_tab",
          br(),
          plotlyOutput("militarymap", height = "650px"),
          br(),
          p(
            HTML(
              '<b>Source:</b> <a href=" https://archive.ourworldindata.org/20260304-094028/grapher/military-spending-as-a-share-of-gdp-sipri.html" target="_blank">
              Stockholm International Peace Research Institute (2025) – with minor processing by Our World in Data
              </a><br>
              Stockholm International Peace Research Institute (2025) – with minor processing by Our World in Data. “Military spending as a share of GDP” [dataset]. Stockholm International Peace Research Institute, “SIPRI Military Expenditure Database” [original data]. Retrieved March 11, 2026. World boundaries from Natural Earth.'
            )
          )
        ),
        
        tabPanel(
          title = "Line Graph",
          value = "line_tab",
          br(),
          plotlyOutput("linegraph", height = "650px"),
          br(),
          p(
            HTML(
              '<b>Source:</b> <a href=" https://archive.ourworldindata.org/20260304-094028/grapher/military-spending-as-a-share-of-gdp-sipri.html" target="_blank">
              Stockholm International Peace Research Institute (2025) – with minor processing by Our World in Data
              </a><br>
              Stockholm International Peace Research Institute (2025) – with minor processing by Our World in Data. “Military spending as a share of GDP” [dataset]. Stockholm International Peace Research Institute, “SIPRI Military Expenditure Database” [original data]. Retrieved March 11, 2026.'
            )
          )
        )
      )
    )
  )
)

# =========================
# Server
# =========================
server <- function(input, output) {
  
  output$militarymap <- renderPlotly({
    military_map(input$yr)
  })
  
  output$linegraph <- renderPlotly({
    military_line_plot(input$yr, as.numeric(input$top_n))
  })
}

# =========================
# Run app
# =========================
shinyApp(ui = ui, server = server)