library(mapview)
library(sf)

area_estudio <- st_read("datos/limites/snaspe_lauca.shp")

mapview(area_estudio,
        col.regions = "#00CD66",
        layer.name = "Parque Nacional Lauca")
