library(terra)
library(sf)
library(tidyverse)

ndvi_lauca <- rast("datos/ndvi/ndvi_lauca_2014_2024.tif")
precipitaciones <- read_csv("datos/clima/EC_precipitaciones_mensual_ajata.csv")
snaspe_lauca <- st_read("datos/limites/snaspe_lauca.shp")
cob_vegetacion <- st_read("datos/catastro/catastro_lauca_uso_filter.shp")

# 1) preparar datos ----------------------------------------------------------
precipitaciones <- precipitaciones |>
  mutate(mes = as.numeric(mes)) |>
  group_by(agno, mes) |>
  summarise(precipitacion_acumulada_mensual = sum(valor, na.rm = TRUE),
            .groups = "drop") |>
  mutate(fecha = make_date(agno, mes, 1))

## definir paleta de colores
colores_cobertura <- c(
  "Bosques" = "#228B22",
  "Humedales" = "#6495ED",
  "Praderas y Matorrales" = "#D2B48C"
)

# 2) CRS ------------------------------------------------------------------

crs_raster <- crs(ndvi_lauca)
cob_vegetacion <- st_transform(cob_vegetacion, crs_raster)
snaspe_lauca <- st_transform(snaspe_lauca, crs_raster)


# 3) ndvi por cobertura ---------------------------------------------------

ndvi_por_cobertura <- exact_extract(ndvi_lauca, cob_vegetacion,
                                    fun = NULL,
                                    include_cols = "USO", progress = TRUE)

ndvi_largo <- bind_rows(ndvi_por_cobertura) |>
  select(-coverage_fraction) |>
  pivot_longer(
    cols = -USO,
    names_to = "nombre",
    values_to = "ndvi_valor"
  ) |>
  mutate(
    fecha_str = str_extract(nombre, "\\d{4}-\\d{2}"), #buscar el mes en la fecha
    fecha = ym(fecha_str),
    agno = year(fecha),
    mes = month(fecha)
  ) |>
  filter(!is.na(ndvi_valor))

ndvi_mensual <- ndvi_largo |> #calcular ndvi mensual
  group_by(USO, fecha, agno, mes) |>
  summarise(ndvi_promedio = mean(ndvi_valor, na.rm = TRUE), .groups = "drop") #calcular ndvi mensual mean


# 3) comparacion clima-ndvi -----------------------------------------------

comparacion <- ndvi_mensual |>
  left_join(precipitaciones, by = c("fecha", "agno", "mes"))

estacionalidad <- comparacion |>
  group_by(USO, mes) |>
  summarise(
    ndvi_promedio = mean(ndvi_promedio, na.rm = TRUE),
    ndvi_sd = sd(ndvi_promedio, na.rm = TRUE),
    precip_promedio = mean(precipitacion_acumulada_mensual, na.rm = TRUE),
    .groups = "drop"
  )

factor_escala <- max(estacionalidad$precip_promedio, na.rm = TRUE) /
  max(estacionalidad$ndvi_promedio, na.rm = TRUE)

grafico_comparacion <- ggplot(estacionalidad, aes(x = mes)) +
  annotate("rect", xmin = 0.5, xmax = 3.5, ymin = -Inf, ymax = Inf,
           fill = "gray80", alpha = 0.3) +
  annotate("rect", xmin = 11.5, xmax = 12.5, ymin = -Inf, ymax = Inf,
           fill = "gray80", alpha = 0.3) +
  geom_col(aes(y = precip_promedio / factor_escala), fill = "#08519c", alpha = 0.3, width = 0.7) +
  geom_ribbon(aes(y = ndvi_promedio, ymin = ndvi_promedio - ndvi_sd,
                  ymax = ndvi_promedio + ndvi_sd, fill = USO),
              alpha = 0.2, color = NA) +
  geom_line(aes(y = ndvi_promedio, color = USO), linewidth = 1) +
  geom_point(aes(y = ndvi_promedio, color = USO), size = 2) +
  scale_color_manual(values = colores_cobertura) +
  scale_fill_manual(values = colores_cobertura) +
  scale_x_continuous(breaks = 1:12, labels = c("Ene", "Feb", "Mar", "Abr", "May", "Jun",
                                               "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")) +
  scale_y_continuous(
    name = "NDVI promedio",
    sec.axis = sec_axis(~ . * factor_escala, name = "Precipitación (mm)")
  ) +
  facet_wrap(~USO, ncol = 1) +
  labs(
    title = "Relación estacionalidad precipitaciones y productividad de la vegetación",
    x = NULL,
    caption = "Barras: precipitación mensual promedio. Líneas NDVI promedio mensual"
  ) +
  theme_minimal() +
  guides(color = "none", fill = "none") +
  theme(
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(color = "black", size = 8),
    axis.line = element_line(color = "black"),
    panel.grid = element_blank(),
    strip.text = element_text(face = "bold", size = 10)
  )

grafico_comparacion
