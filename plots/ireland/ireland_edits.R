library(magick)
library(MetBrewer)
library(colorspace)
library(ggplot2)

img <- image_read("ireland_plot_2.png")

print(img)

colours <- met.brewer('VanGogh3')
swatchplot(colours)


img |>
  image_annotate('Ireland',
                 gravity = 'northwest',
                 location = '+400+300',
                 color = colours[7],
                 font = 'Stonehenge',
                 size = 400) |>
  image_annotate('Population Density',
                 gravity = 'northwest',
                 location = '+460+700',
                 color = colours[7],
                 font = 'Stonehenge',
                 size = 120) |>
  image_annotate("Kontur Population Dataset 2022",
                 gravity = 'southeast',
                 location = '+200+100',
                 color = alpha(colours[7],0.75),
                 size = 80) |>
  image_annotate("Visualised by Tom Walsh",
                 gravity = 'southeast',
                 location = '+200+200',
                 color = alpha(colours[7],0.75),
                 size = 80) |>
  image_annotate("Dublin",
                 gravity = 'east',
                 location = '+1100-190',
                 color = colours[7],
                 size = 100,
                 weight = 10000,
                 font = 'Stonehenge') |>
  image_annotate("Cork",
                 gravity = 'south',
                 location = '-200+1050',
                 color = colours[7],
                 size = 100,
                 weight = 10000,
                 font = 'Stonehenge') |>
  image_annotate("Galway",
                 gravity = 'west',
                 location = '+1050+450',
                 color = colours[7],
                 size = 100,
                 weight = 10000,
                 font = 'Stonehenge') |>
  image_annotate("Belfast",
                 gravity = 'northeast',
                 location = '+700+1700',
                 color = colours[7],
                 size = 100,
                 weight = 10000,
                 font = 'Stonehenge') |>
  image_annotate("__________",
                 gravity = 'west',
                 location = '+1400+400',
                 color = colours[7],
                 size = 100,
                 weight = 10000,
                 font = 'Stonehenge',
                 degrees = 352) |>
  image_write('ireland_pop_density.png')
