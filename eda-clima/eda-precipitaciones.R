library(tidyverse)
library(plotly)

precipitaciones <- read_csv("datos/clima/EC_precipitaciones_mensual_ajata.csv")

# 1) Preparar datos -------------------------------------------------------
precipitaciones <- precipitaciones |>
  mutate(mes = as.numeric(mes)) |>
  group_by(agno, mes) |>
  summarise(precipitacion_acumulada_mensual = sum(valor, na.rm = TRUE),
            .groups = "drop") |>
  mutate(fecha = make_date(agno, mes, 1))

# 2) Serie temporal interactiva (plotly) ----------------------------------
precipitaciones_reciente <- precipitaciones |>
  filter(agno >= 2014)

grafico_serie_plotly <- plot_ly(
  precipitaciones_reciente,
  x = ~fecha,
  y = ~precipitacion_acumulada_mensual,
  type = "bar",
  marker = list(
    color = ~precipitacion_acumulada_mensual,
    colorscale = list(c(0, "#deebf7"), c(1, "#08519c")),
    showscale = FALSE
  )
) |>
  layout(
    title = list(
      text = "<b>Precipitación acumulada mensual</b><br><sub>Parque Nacional Lauca (2014-2024)</sub>",
      font = list(color = "black")
    ),
    xaxis = list(title = "", rangeslider = list(visible = TRUE)),
    yaxis = list(title = "Precipitación (mm)")
  )

grafico_serie_plotly

# 3) Estacionalidad (ggplot) ----------------------------------------------
estacionalidad <- precipitaciones |>
  group_by(mes) |>
  summarise(
    promedio = mean(precipitacion_acumulada_mensual),
    sd = sd(precipitacion_acumulada_mensual)
  )

promedio_anual <- mean(estacionalidad$promedio)

grafico_estacionalidad <- ggplot(estacionalidad, aes(x = factor(mes), y = promedio, fill = promedio)) +
  annotate("rect", xmin = 0.5, xmax = 3.5, ymin = 0, ymax = Inf,
           fill = "#08519c", alpha = 0.08) +
  geom_col(color = "white") +
  geom_text(aes(label = round(promedio, 1)),
            vjust = -0.5, size = 2.8, color = "black") +
  geom_hline(yintercept = promedio_anual, linetype = "dashed", color = "black", linewidth = 0.5) +
  scale_fill_gradient(low = "#deebf7", high = "#08519c") +
  scale_x_discrete(labels = c("Ene", "Feb", "Mar", "Abr", "May", "Jun",
                              "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(
    title = "Estacionalidad de Precipitación",
    subtitle = "Parque Nacional Lauca (1983-2024)",
    x = NULL,
    y = "Precipitación promedio (mm)",
    caption = "Línea punteada: promedio mensual. Sombreado: estación lluviosa (Ene-Mar)"
  ) +
  theme_minimal() +
  guides(fill = "none") +
  theme(
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(color = "black", size = 8),
    axis.line = element_line(color = "black"),
    panel.grid = element_blank()
  )

grafico_estacionalidad


# 4) Exportar gráficos -------------------------------------------------------

if (!dir.exists("eda-clima/figuras")) {
  dir.create("eda-clima/figuras")
}

# Exportar gráfico de estacionalidad (ggplot) ----
ggsave(
  filename = "eda-clima/figuras/estacionalidad_precipitacion.png",
  plot = grafico_estacionalidad,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# Exportar gráfico interactivo (plotly)----
htmlwidgets::saveWidget(
  widget = grafico_serie_plotly,
  file = "eda-clima/figuras/serie_precipitacion.html",
  selfcontained = TRUE
)
