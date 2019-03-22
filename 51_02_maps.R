rm(list = ls())
setwd("Y:/agrajg/Research/Paper1_demand_stata")
.libPaths(new = c("Y:/agrajg/Research/Paper1/packrat/lib/x86_64-w64-mingw32/3.4.3",
                  "H:/agrajg/R",
                  "H:/agrajg/R2"))
# install.packages(c("cowplot", "googleway", "ggplot2", "ggrepel", "ggspatial", "libwgeom", "sf", "rnaturalearth", "rnaturalearthdata"))


library(tigris)
library(dplyr)
library(leaflet)
library(sp)
library(ggmap)
library(maptools)
library(broom)
library(httr)
library(rgdal)

r <- GET('http://data.beta.nyc//dataset/0ff93d2d-90ba-457c-9f7e-39e47bf2ac5f/resource/35dd04fb-81b3-479b-a074-a27a37888ce7/download/d085e2f8d0b54d4590b1e7d1f35594c1pediacitiesnycneighborhoods.geojson')

nyc_neighborhoods <- readOGR(content(r,'text'), 'OGRGeoJSON', verbose = F)

summary(nyc_neighborhoods)
nyc_neighborhoods_df <- tidy(nyc_neighborhoods)

ggmap(nyc_map) + 
  geom_polygon(data=nyc_neighborhoods_df, aes(x=long, y=lat, group=group), color="blue", fill=NA)