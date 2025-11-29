library(sf)
library(tidyverse)
library(plotly)

area_estudio <- st_read("datos/limites/snaspe_lauca.shp")
cob_suelo <- st_read("datos/catastro/catastro_lauca_uso_filter.shp")

colores_cobertura <- c(
  "Bosques" = "#228B22",
  "Humedales" = "#6495ED",
  "Praderas y Matorrales" = "#D2B48C"
)



names(cob_suelo)
head(cob_suelo)

unique(cob_suelo$USO)
#[1] "Praderas y Matorrales" "Humedales"             "Bosques"

cob_suelo <- cob_suelo %>%
  mutate(area_ha = as.numeric(st_area(geometry)) / 10000)

resumen_cob <- cob_suelo %>%
  st_drop_geometry() %>%
  group_by(USO) %>%
  summarise(area_ha = sum(area_ha)) %>%
  mutate(porcentaje = round(area_ha / sum(area_ha) * 100, 1))

resumen_cob

## grafico de torta ----

plot_ly(resumen_cob,
        labels = ~USO,
        values = ~area_ha,
        type = 'pie',
        marker = list(colors = c("#228B22", "#6495ED", "#D2B48C")),
        textinfo = 'label+percent',
        hovertemplate = "%{label}<br>%{value:.0f} ha<br>%{percent}<extra></extra>")
