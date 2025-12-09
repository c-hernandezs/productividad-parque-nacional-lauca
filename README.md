# 🌿 **Visualización Dinámica de Productividad Altiplánica** 🏔️
## Series Temporales NDVI • Parque Nacional Lauca

---

## ❓ **Pregunta de Investigación**
¿Cómo varían los patrones de productividad vegetal entre bofedales, matorrales y bosques en el Parque Nacional Lauca, y cómo se relacionan con precipitación desde el 2014 al 2024? 🌧️📈

## 🧪 **Hipótesis Principal**
**Bofedales** responden más rápido a lluvias, **matorrales** muestran desfases y **bosques** mantienen productividad basal estable.

## 🎯 **Objetivo**
Visualizar **patrones de productividad** de ecosistemas altiplánicos del norte chileno usando **NDVI Landsat** (30m/16 días) y correlacionarlos con variables climáticas CR2MET. 🛰️

---

## 📊 **Datos Utilizados**

### 🛰️ **NDVI Landsat 8/9**
| Especificación     | Detalle                  |
|--------------------|--------------------------|
| **Plataforma**     | Google Earth Engine      |
| **Período**        | 2014 - 2024              |
| **Resolución**     | 30m / 16 días            |
| **Fórmula**        | \( NDVI = \frac{NIR-Red}{NIR+Red} \) |
| **Formato**        | GeoTIFF                  |

### 🌤️ **CR2MET Clima**
- **Variables**: Precipitación (mm/día)
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
├── README.md                         
│
├── datos/                             # Datos de entrada
│   ├── catastro-veg/                  # Coberturas vegetacionales CONAF
│   │   └── catastro_uso_lauca.shp
│   ├── limites/                       # Límites de parques nacionales
│   │   └── snaspe_lauca.shp
│   ├── ndvi/                          # Series temporales NDVI - Lansat
│   │   └── serie_ndvi_lauca.tif
│   └── clima/                         # Datos climáticos CR2MET
│       ├── precipitacion_2014_2024.csv
│       └── temperatura_2014_2024.csv
│
├── eda-clima/                               # Análisis Exploratorio de Datos
│   ├── codigos/
│   │   └── eda_precipitaciones.R
│   └── figuras/
│       ├── estacionalidad_precipitacion.png
│       └── serie_precipitacion.html
│
├── eda-NDVI/                         # Análisis NDVI
│   ├── codigos/
│   │   └── eda_ndvi.R
│   │   
│   └── figuras/
│       ├── estacionalidad_ndvi_coberturas.png
│       ├── ndvi_coberturas.png
│       └── serie_ndvi_cobertura.html
│
└── clima-ndvi/                 # Análisis NDVI-Clima
    ├── codigos/
    │   └── comparacion_clima_ndvi.R
    │   
    └── figuras/
        └── clima_ndvi.png

````
---

## **Conclusiones**

Los bofedales son los más productivos pero también los más vulnerables: presentan los valores de NDVI más altos, pero su mayor variabilidad interanual indica sensibilidad a las fluctuaciones hídricas.
Existe un desfase de ~1 mes entre lluvias y respuesta vegetal: el peak de precipitación ocurre en enero-febrero, mientras que el máximo de productividad se alcanza en marzo-abril.
Praderas y matorrales mantienen estabilidad a costa de baja productividad: sus valores de NDVI se mantienen bajos y constantes independiente de las variaciones climáticas.

---

## 👥 **Audiencia**
Este proyecto está dirigido al público general interesado en conservación, especialmente quienes buscan comprender cómo responden los ecosistemas altiplánicos al clima. No requiere conocimientos técnicos previos - las visualizaciones interactivas permiten explorar los datos de forma intuitiva.


## 👩‍🔬 **Autora**
**🌟 Constanza Hernández**  
*Magíster en Recursos Naturales*  
**Pontificia Universidad Católica de Chile**  
**AGP3141 - Visualización de Datos Ambientales en R**  
*Primavera 2025*

🛠️ R - Quarto - sf/tidyverse - plotly - mapview

🗺️ EPSG:4326 - Google Earth Engine


---

**¡Explora la dinámica del Altiplano!** 🌄✨


