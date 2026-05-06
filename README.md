# Military Spending as a Share of GDP — Interactive Visualization

> An R-based data visualization lab exploring global military expenditure as a percentage of GDP, featuring an interactive choropleth world map and a multi-country line graph of historical trends.

*Date: 2026-03-08*

---

## Project Description

This lab project visualizes **global military spending data** sourced from SIPRI (Stockholm International Peace Research Institute) via Our World in Data. Using R and interactive plotting libraries, it produces two complementary visualizations:

1. **A choropleth world map** — showing each country's military expenditure as a share of GDP for a given year, with hover tooltips for country-level detail
2. **A line graph** — tracking the top 10 countries by peak military spending over time, allowing historical trend comparison across nations

The goal is to make military spending patterns accessible and explorable through clean, interactive visuals rather than static tables.

---

## Dataset

**Source:** [Our World in Data — Military Expenditure (% of GDP)](https://ourworldindata.org/military-spending), based on SIPRI data

**File:** `military-spending-as-a-share-of-gdp-sipri.csv`

### Key Columns

| Column | Description |
|---|---|
| `Entity` | Country or region name |
| `Code` | ISO-3 country code |
| `Year` | Year of observation |
| `Military.expenditure....of.GDP.` | Military spending as % of GDP (renamed to `spendingPCT`) |
| `World.region.according.to.OWID` | World region classification (renamed to `worldRegion`) |

---

## Requirements

This project is written in **R** and rendered as an R Markdown (`.Rmd`) document.(download R Studio for a better visualization

### R Packages

```r
install.packages(c("tidyverse", "ggplot2", "plotly", "openintro", "rnaturalearth", "rnaturalearthdata"))
```

| Package | Purpose |
|---|---|
| `tidyverse` | Data wrangling and piping |
| `ggplot2` | Base map and chart rendering |
| `plotly` | Converting ggplot to interactive visualizations |
| `rnaturalearth` / `rnaturalearthdata` | World map geometries (sf format) |
| `openintro` | Supplemental data utilities |

---

## How to Run

1. Place `military-spending-as-a-share-of-gdp-sipri.csv` in the project directory (update the file path in the script if needed).
2. Open `lab.Rmd` in RStudio.
3. Click **Knit** to render the full HTML report, or run chunks individually.

> The rendered output is also available as `lab.html` — open it in any browser for the interactive visualizations.

---

## Visualizations

### 1. Choropleth Map — Military Spending by Country (2024)

Built with `rnaturalearth` (for world geometry) joined with the SIPRI dataset, filtered to **2024**. Two versions are produced:

- A `ggplot2` + `ggplotly` version with hover tooltips showing country name and spending %
- A `plot_ly` choropleth using ISO-3 country codes, natural earth projection, with a **Yellow → Orange → Red** (`YlOrRd`) color scale

Countries with higher military spending as a share of GDP appear in deeper red; countries with lower spending appear in yellow.

### 2. Line Graph — Top 10 Countries by Peak Military Spending Over Time

Filters to the **top 10 countries** ranked by their historical peak military spending percentage, then plots each country's spending trajectory over all available years. Built with `plotly` for interactive hover tooltips showing country name, year, and spending %.

---

## Project Structure

```
├── lab.Rmd                                              # R Markdown source
├── lab.html                                             # Rendered interactive report
├── military-spending-as-a-share-of-gdp-sipri.csv       # Dataset (SIPRI via OWID)
└── README.md                                            # This file
```

---

## Notes

- The choropleth map filters out rows with missing ISO-3 codes or missing spending values to ensure clean joins with world geometry.
- The line graph top-10 ranking is based on each country's **all-time maximum** spending percentage, not the most recent year.
- Year 2024 is used for the map snapshot; historical coverage varies by country in the SIPRI dataset.
- File paths in the `.Rmd` source use an absolute local path (`~/Intro_to_R/...`) — update this to match your local directory structure before running.
