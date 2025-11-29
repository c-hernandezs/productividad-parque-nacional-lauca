# 🌿 **Visualización Dinámica de Productividad Altiplánica** 🏔️
## Series Temporales NDVI • Parque Nacional Lauca

---

## ❓ **Pregunta de Investigación**
¿Cómo varían los patrones de **productividad vegetal** entre **bofedales, matorrales y bosques** en el Parque Nacional Lauca, y cómo se relacionan con **precipitación y temperatura** (2014-2024)? 🌧️📈

## 🧪 **Hipótesis Principal**
**Bofedales** responden más rápido a lluvias, **matorrales** muestran desfases y **bosques** mantienen productividad basal estable.

## 🎯 **Objetivo**
Visualizar **patrones fenológicos** de ecosistemas altiplánicos del norte chileno usando **NDVI Landsat** (30m/16 días) y correlacionarlos con variables climáticas CR2MET. 🛰️

---

## 📊 **Datos Utilizados**

### 🛰️ **NDVI Landsat 8/9**
| Especificación     | Detalle                  |
|--------------------|--------------------------|
| **Plataforma**     | Google Earth Engine      |
| **Período**        | 2014-2024                |
| **Resolución**     | 30m / 16 días            |
| **Fórmula**        | \( NDVI = \frac{NIR-Red}{NIR+Red} \) |
| **Formato**        | GeoTIFF                  |

### 🌤️ **CR2MET Clima**
- **Variables**: Precipitación (mm/día), Temperatura (°C)
- **Resolución**: ~5km / Diaria
- **Fuente**: Centro de Ciencia del Clima y la Resiliencia

### 🗺️ **Áreas de Estudio**
🏔️ Parque Nacional Lauca (SNASPE)
🌱 Coberturas: Bofedales - Matorrales-pastizales - Bosques (CONAF)
- **Fuente:** SNASPE (Sistema Nacional de Áreas Silvestres Protegidas del Estado)


## 📁 **Estructura del Proyecto**
```
agp3141-fenologia-ecosistemas-altiplanicos/
│
├── README.md                          # Este archivo
│
├── datos/                             # Datos de entrada
│   ├── catastro-veg/                  # Coberturas vegetacionales CONAF
│   │   └── catastro_uso_lauca.shp
│   ├── limites/                       # Límites de parques nacionales
│   │   └── snaspe_lauca.shp
│   ├── ndvi/                          # Series temporales NDVI
│   │   └── serie_ndvi_lauca.tif
│   └── clima/                         # Datos climáticos CR2MET
│       ├── precipitacion_2014_2024.csv
│       └── temperatura_2014_2024.csv
│
├── eda-clima/                               # Análisis Exploratorio de Datos
│   ├── codigos/
│   │   └── eda_clima.R
│   └── figuras/
│       └── plot_serie_prep_acum.png
│       └── plot_serie_temp_media.png
│
├── eda-NDVI/                         # Análisis NDVI
│   ├── codigos/
│   │   └── NDVI_por_cobsuelo.R
│   │   
│   └── figuras/
│       ├── plot_mapas_ndvi_y_serie.png
│       
│
└── NDVI-y-clima/                 # Análisis NDVI-Clima
    ├── codigos/
    │   ├── comparacion_clima_ndvi.R
    │   └── visualizacion_comparacion.R
    └── figuras/
        └── plot_series_comparadas.png

````

---

## 👩‍🔬 **Autora**
**🌟 Constanza Hernández**  
*Magíster en Recursos Naturales*  
**Pontificia Universidad Católica de Chile**  
**AGP3141 - Visualización de Datos Ambientales en R**  
*Primavera 2025*

🛠️ R - Quarto - sf/tidyverse - plotly - mapview
🗺️ EPSG:4326 - Google Earth Engine


---

**¡Explora la dinámica verde del Altiplano!** 🌄✨


