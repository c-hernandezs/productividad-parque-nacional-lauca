library(terra)
library(ggplot2)
library(sf)
library(tidyverse)
library(tidyterra)
library(patchwork)
library(exactextractr)
library(plotly)

ndvi_lauca <- rast("datos/ndvi/ndvi_lauca_2014_2024.tif")
cob_vegetacion <- st_read("datos/catastro/catastro_lauca_uso.shp")
snaspe_lauca <- st_read("datos/limites/snaspe_lauca.shp")


# 1) preparar datos cob suelo ----------------------------------------------

glimpse(cob_vegetacion)
plot(cob_vegetacion["USO"])
unique(cob_vegetacion$USO)

cob_vegetacion_filtrado <- cob_vegetacion |>
  filter(USO %in% c("Praderas y Matorrales", "Humedales", "Bosques"))

#plot(cob_vegetacion_filtrado["USO"])

## definir paleta de colores ----
colores_cobertura <- c(
  "Bosques" = "#228B22",
  "Humedales" = "#6495ED",
  "Praderas y Matorrales" = "#D2B48C"
)


# 2) Agrupar NDVI ---------------------------------------------------------

names(ndvi_lauca)

## identificar meses ----
meses <- as.numeric(sub(".*-(\\d{2})$", "\\1", names(ndvi_lauca)))
meses_lluvioso <- c(12, 1, 2, 3)
meses_no_lluvioso <- c(6, 7, 8, 9)

ndvi_lluvioso <- ndvi_lauca[[meses %in% meses_lluvioso]]
ndvi_no_lluvioso <- ndvi_lauca[[meses %in% meses_no_lluvioso]]

ndvi_mediana_lluvioso <- app(ndvi_lluvioso, fun = median, na.rm = TRUE)
ndvi_mediana_no_lluvioso <- app(ndvi_no_lluvioso, fun = median, na.rm = TRUE)

## revisar crs ----
crs_raster <- crs(ndvi_lauca)
snaspe_lauca <- st_transform(snaspe_lauca, crs_raster)
cob_vegetacion_filtrado <- st_transform(cob_vegetacion_filtrado, crs_raster)


# 3) Composición de mapas -------------------------------------------------

## paneles para grafico ----
p1 <- ggplot() +
  geom_sf(data = cob_vegetacion_filtrado, aes(fill = USO), color = NA) +
  geom_sf(data = snaspe_lauca, fill = NA, color = "black", linewidth = 0.2) +
  scale_fill_manual(
    values = colores_cobertura,
    name = "Cobertura"
  ) +
  labs(title = "") +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.line = element_blank(),
    panel.grid = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold")
  )

p2 <- ggplot() +
  geom_spatraster(data = ndvi_mediana_lluvioso) +
  geom_sf(data = snaspe_lauca, fill = NA, color = "black", linewidth = 0.2) +
  scale_fill_distiller(palette = "Greens", direction = 1, limits = c(0, 0.5),
                       na.value = "transparent", name = "NDVI") +
  labs(title = "NDVI - Período lluvioso") +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.line = element_blank(),
    panel.grid = element_blank(),
    legend.position = "none",
    plot.title = element_text(face = "bold")
  )

p3 <- ggplot() +
  geom_spatraster(data = ndvi_mediana_no_lluvioso) +
  geom_sf(data = snaspe_lauca, fill = NA, color = "black", linewidth = 0.2) +
  scale_fill_distiller(palette = "Greens", direction = 1, limits = c(0, 0.5),
                       na.value = "transparent", name = "NDVI") +
  labs(title = "NDVI - Período seco") +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.line = element_blank(),
    panel.grid = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold")
  )

## grafico final ----
fila_ndvi <- p2 + p3 + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

composicion <- (p1 | fila_ndvi) +
  plot_annotation(
    caption = "Período lluvioso: diciembre - marzo | Período seco: junio - septiembre\nFuente: Landsat Collection 2, CONAF. Período 2014-2024."
  ) &
  theme(
    plot.caption = element_text(
      hjust = 0,
      size = 9,
      color = "black",
      lineheight = 1.2
    )
  )

composicion


# 4) NDVI por cobertura ---------------------------------------------------

ndvi_por_cobertura <- exact_extract(ndvi_lauca, cob_vegetacion_filtrado,
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
    fecha_str = str_extract(nombre, "\\d{4}-\\d{2}"),
    fecha = ym(fecha_str),
    agno = year(fecha),
    mes = month(fecha)
  ) |>
  filter(!is.na(ndvi_valor))


# 5) serie temporal interactivo -------------------------------------------

ndvi_serie <- ndvi_largo |>
  group_by(USO, fecha) |>
  summarise(ndvi_mediana = median(ndvi_valor, na.rm = TRUE), .groups = "drop")

## grafico plotly ----

grafico_ndvi_plotly <- plot_ly() |>
  add_trace(
    data = ndvi_serie |> filter(USO == "Bosques"),
    x = ~fecha, y = ~ndvi_mediana,
    type = "scatter", mode = "lines",
    name = "Bosques",
    line = list(color = "#228B22", width = 2)
  ) |>
  add_trace(
    data = ndvi_serie |> filter(USO == "Humedales"),
    x = ~fecha, y = ~ndvi_mediana,
    type = "scatter", mode = "lines",
    name = "Humedales",
    line = list(color = "#6495ED", width = 2)
  ) |>
  add_trace(
    data = ndvi_serie |> filter(USO == "Praderas y Matorrales"),
    x = ~fecha, y = ~ndvi_mediana,
    type = "scatter", mode = "lines",
    name = "Praderas y Matorrales",
    line = list(color = "#D2B48C", width = 2)
  ) |>
  layout(
    title = list(
      text = "<b>Serie temporal de NDVI por cobertura</b><br><sub>Parque Nacional Lauca (2014-2024)</sub>",
      font = list(color = "black")
    ),
    xaxis = list(title = "", rangeslider = list(visible = TRUE)),
    yaxis = list(title = "NDVI (mediana)"),
    legend = list(orientation = "h", y = -0.2)
  )

grafico_ndvi_plotly


# 6) grafico estacionalidad -----------------------------------------------

estacionalidad_ndvi <- ndvi_largo |>
  group_by(USO, mes) |>
  summarise(
    promedio = mean(ndvi_valor, na.rm = TRUE),
    sd = sd(ndvi_valor, na.rm = TRUE),
    .groups = "drop"
  )

## Gráfico de estacionalidad ----
grafico_estacionalidad_ndvi <- ggplot(estacionalidad_ndvi, aes(x = mes, y = promedio, color = USO, fill = USO)) +
  annotate("rect", xmin = 0.5, xmax = 3.5, ymin = -Inf, ymax = Inf,
           fill = "gray80", alpha = 0.3) +
  annotate("rect", xmin = 11.5, xmax = 12.5, ymin = -Inf, ymax = Inf,
           fill = "gray80", alpha = 0.3) +
  geom_ribbon(aes(ymin = promedio - sd, ymax = promedio + sd), alpha = 0.2, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = colores_cobertura) +
  scale_fill_manual(values = colores_cobertura) +
  scale_x_continuous(breaks = 1:12, labels = c("Ene", "Feb", "Mar", "Abr", "May", "Jun",
                                               "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")) +
  labs(
    title = "Ciclo estacional de NDVI por tipo de cobertura",
    subtitle = "Parque Nacional Lauca (2014-2024)",
    x = NULL,
    y = "NDVI promedio",
    color = "Cobertura",
    fill = "Cobertura",
    caption = "Banda: ± 1 desviación estándar. Sombreado: estación lluviosa (Dic-Mar)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(color = "black", size = 8),
    axis.line = element_line(color = "black"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

grafico_estacionalidad_ndvi
