library(sf)
library(tidyverse)

area_estudio <- st_read("datos/limites/snaspe_lauca.shp")
cob_suelo <- st_read("datos/catastro/catastro_lauca_uso_filter.shp")

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

# Gráfico de torta
ggplot(resumen_cob, aes(x = "", y = porcentaje, fill = USO)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  scale_fill_manual(values = c("Bosques" = "#228B22",
                               "Humedales" = "#4169E1",
                               "Praderas y Matorrales" = "#9ACD32")) +
  labs(fill = "Cobertura") +
  theme_void() +
  geom_text(aes(label = paste0(porcentaje, "%")),
            position = position_stack(vjust = 0.5),
            color = "white", fontface = "bold")
