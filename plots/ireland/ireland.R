# Load libraries
library(sf)
library(tidyverse)
library(elevatr)
library(rayshader)
library(rayrender)
library(glue)
library(colorspace)
library(tigris)
library(stars)
library(MetBrewer)
testing
# Load and combine Irish and UK data
roi_data <- st_read('kontur_population_IE_20220630.gpkg')
uk_data <- st_read('kontur_population_GB_20220630.gpkg')

data <- rbind(roi_data,uk_data)

# Load Republic of Ireland boundary polygons
roi <- raster::getData(name = 'GADM', country = 'IRL', level = 0) %>% st_as_sf()

# Plot Ireland
roi |>
  ggplot() +
  geom_sf()

# Load UK boundary polygons and filter for Northern Ireland only
ni <- raster::getData(name = 'GADM', country = 'GBR', level = 1) %>% st_as_sf() %>%
  filter(NAME_1 == 'Northern Ireland')

# Plot Northern Irealnd
ni |>
  ggplot() +
  geom_sf()

# Combine Ireland and Northern Ireland boundary polygons
ni <- ni[c('GID_0','NAME_0','geometry')]

ireland <- rbind(roi,ni)

# Plot Ireland
ireland |>
  ggplot() +
  geom_sf()

# Match CRS (Coordinate Reference System) of population and boundary data
ireland <- st_transform(ireland,st_crs(data))

# Plot again, image will shift slightly
ireland |>
  ggplot() +
  geom_sf()

# Filter population data for only what is within the Ireland boundary
ireland_data <- st_intersection(data,ireland)

# Define aspect ratio for matrix using bounding box so we can covert data to matrix
bb <- st_bbox(ireland_data)
bb

# Convert bb numbers to point coordinates
bottom_left <- st_point(c(bb[['xmin']], bb[['ymin']])) |>
  st_sfc(crs = st_crs(ireland_data))

bottom_right <- st_point(c(bb[['xmax']], bb[['ymin']])) |>
  st_sfc(crs = st_crs(ireland_data))

# Plot map with bottom left and bottom right coordinates
ireland |>
  ggplot() +
  geom_sf() +
  geom_sf(data = bottom_left) +
  geom_sf(data = bottom_right, color = 'red')

# Get width
width <- st_distance(bottom_left, bottom_right)
width

# Get height
top_left <- st_point(c(bb[['xmin']], bb[['ymax']])) |>
  st_sfc(crs = st_crs(ireland_data))

height <- st_distance(bottom_left, top_left)
height

height > width
height - width

# Get width and height ratios in conditions where width > height and vice versa
if (width > height) {
  w_ratio <- 1
  h_ratio <- height/width
} else {
  h_ratio <- 1
  w_ratio <- width/height
}

# Covert geo data to raster
size <- 6000

ireland_rast <- st_rasterize(ireland_data,
                             nx=floor(size*as.numeric(w_ratio)),
                             ny=floor(size*as.numeric(h_ratio)))

# Convert raster to matrix
mat <- matrix(ireland_rast$population,
              nrow = floor(size*as.numeric(w_ratio)),
              ncol = floor(size*as.numeric(h_ratio)))

# Create colour palette
c1 <- met.brewer('VanGogh3')
swatchplot(c1)

texture <- grDevices::colorRampPalette(c1,bias=2)(256)
swatchplot(texture)

# Plot in 3D in RGL object
rgl::rgl.close()

mat |>
  height_shade(texture = texture) |>
  plot_3d(heightmap = mat,
          zscale = 10,
          solid = FALSE,
          shadowdepth = 0)

# Adjust the angle
render_camera(theta = 15, phi = 45, zoom = 0.70)

# Render image in high quality
outfile <- "final_plot.png"

{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), "\n")
  if (!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  render_highquality(
    filename = outfile,
    interactive = FALSE,
    lightdirection = 220,
    lightaltitude = c(20,80),
    lightcolor = c(c1[1],'white'),
    lightintensity = c(600, 100),
    samples = 450,
    width = 6000,
    height = 6000
  )
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), "\n")
}
