# Mandelbrot Set / Julia Set visualization using Elixir/Scenic

## Overview

Visualize [Mandlebrot Set](https://en.wikipedia.org/wiki/Mandelbrot_set) and [Julia Set](https://en.wikipedia.org/wiki/Julia_set) using [Elixir](https://elixir-lang.org/) with [Scenic library](https://github.com/boydm/scenic).

## Configuration

Configuration is maintained in `config/config.exs` file.
The following can be configured by modifying values in the config file:

Under `config :scenic_test, :viewport`:
1. size - screen size in pixels. Higher the resolution, longer it will take to render.

Under `config :scenic_test, :config`:
1. step_size - resolution for the visualization. Higher numbers result in slower render.
2. clip_start - exclude rendering points with steps lower or equal to this value. White.
3. clip_end - exclude rendering points with steps higher or equal to this value. Black.
4. zoom - zoom factor.
6. render_steps - split the rendering into number of steps to allow visualizing partial sets while render progresses.
6. offset - offset in pixels along `X` and `Y` coordinates.
7. julia_coord - coordinates from `Julia Set` to visualize.
8. render_julia - when `true`, render `Julia Set`, otherwise, render `Mandelbrot Set`.

