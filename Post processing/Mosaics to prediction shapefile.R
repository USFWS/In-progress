
library (raster)
library(sf)
library(sfheaders)
library (lubridate)

# Input: Set working dir for ortho/mosaics
setwd(file.path('C:', 'users', 'Aware', 'desktop', 'project_temp', 'mosaics_project_2025'))

# Inputs: pred1 = table from detection inference depicting predictions: 
# xmin, ymin, w, h
# output_predictions = name of output csv table of georeferenced predictions
# gsd_m = spatial resolution of data
# crs1 = spatial projection-- in utm
# export_spatial = shapefile of predictions to export

pred1 <- read.table ("C:/Users/aware/desktop/project_temp/step1_yolo_survey_2025_west_part2_125k.csv", 
  sep = ",", header=TRUE, fill=TRUE)

output_predictions <- "temp1.csv"
gsd_m = 0.103
# crs1 = 4326 # WGS1984
crs1 = 4487 # utm 14N
export_spatial = "temp.shp"

## List files in dir and get extents
gridz <- list.files (pattern="*tif$")  

extents1 <- data.frame(raster_name=NA, xmin_extent=NA, xmax_extent=NA, ymin_extent=NA, ymax_extent=NA)

for (f in gridz){
  r1 <- raster(f)
  e1 <- extent(r1)
  raster_name <- f
  xmin_extent <- e1[1,]
  xmax_extent <- e1[2,]
  ymin_extent <- e1[3,]
  ymax_extent <- e1[4,]
  vector1 <- c(raster_name, xmin_extent, xmax_extent, ymin_extent, ymax_extent)
  print(vector1)
  extents1 <- rbind(extents1, vector1)
}

extents1$unique_image_jpg <- extents1$raster_name
extents1$raster_name <- NULL

## Merge with predictions
pred1$basename <- basename(pred1$unique_image_jpg)
pred1$unique_image_jpg <- pred1$basename
pred1$basename <- NULL

merge5 <- merge(extents1, pred1, by="unique_image_jpg") 

## Annotations
merge5$xmin_m <- merge5$xmin*gsd_m
merge5$ymin_m <- merge5$ymin*gsd_m

merge5$h_m <- (merge5$h*gsd_m)/2
merge5$w_m <- (merge5$w*gsd_m)/2

merge5[0:6,]

merge5$xmin_extent <- as.numeric(merge5$xmin_extent)
merge5$ymax_extent <- as.numeric(merge5$ymax_extent)
#as.numeric(merge5$xmin_extent)

merge5$x_annot <- merge5$xmin_extent + ((merge5$xmin_m)+ merge5$w_m)
merge5$y_annot <- merge5$ymax_extent - ((merge5$ymin_m)+ merge5$h_m)
merge5$y_annot_above <- merge5$y_annot + 0.10

merge5$x_annot <- as.numeric(merge5$x_annot)
merge5$y_annot <- as.numeric(merge5$y_annot)
merge5$y_annot_above <- as.numeric(merge5$y_annot_above)

# to shapefile
# Projections, crs = 4326--WGS84
merge5 <- merge5[complete.cases(merge5), ]
new_sf <- st_as_sf(merge5, coords = c("x_annot", "y_annot_above"), crs= crs1)

#plot(new_sf)

new_sf %>% 
  st_coordinates()

st_write(new_sf, export_spatial, driver = "ESRI Shapefile")  


