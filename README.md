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

## Compiling and executing

Ensure you have Elixir OTP installed and `mix` is accessible in the `PATH` environment.

From the project folder, run the following commands:

```
mix deps.get
iex -S mix
```
## Example

### Julia Set 

`({-0.8,-0.156})`

![image](https://user-images.githubusercontent.com/1296705/184066319-2da44963-7a6d-4974-8475-ae569986656f.png)

### Mandelbrot Set

![image](https://user-images.githubusercontent.com/1296705/184066563-7b78d953-f270-483b-91b0-dba04bfda8cd.png)

