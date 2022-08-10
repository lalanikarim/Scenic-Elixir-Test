defmodule ScenicTest.Scenic.PreReq do
  import Scenic.Primitives

  @step_size Application.get_env(:scenic_test, :config)[:step_size]
  @zoom Application.get_env(:scenic_test, :config)[:zoom]
  @offset Application.get_env(:scenic_test, :config)[:offset]
  @julia_coord Application.get_env(:scenic_test, :config)[:julia_coord]
  @render_julia Application.get_env(:scenic_test, :config)[:render_julia]
  @clip_start Application.get_env(:scenic_test, :config)[:clip_start]
  @clip_end Application.get_env(:scenic_test, :config)[:clip_end]

  def compute_mandelbrot({width, height} = screen, {x0, y0} = _start \\ {0, 0}) do
    Enum.flat_map(x0..(x0 + width), fn x ->
      Enum.map(y0..(y0 + height), fn y -> {x, y} end)
    end)
    |> Enum.map(fn point -> {point, is_mandelbrot(point, screen)} end)
    |> Enum.filter(fn {_, steps} ->
      steps >= @clip_start and steps <= @clip_end and steps <= @step_size
    end)
  end

  def plot_mandelbrot(graph, screen, start \\ {0, 0}) do
    points = compute_mandelbrot(screen, start)
    IO.inspect({"Start Composition: ", :calendar.local_time()})
    updated = Enum.reduce(points, graph, fn point, graph -> plot_point(graph, point, screen) end)
    IO.inspect({"End Composition: ", :calendar.local_time()})

    updated
  end

  def reduce_plotter(graph, points, screen) do
    Enum.reduce(points, graph, fn point, graph -> plot_point(graph, point, screen) end)
  end

  def map_reduce_plotter(graph, points, screen) do
    graph
    |> add_specs_to_graph(map_to_spec(points, screen))
  end

  def map_to_spec(points, {width, height}) do
    points
    |> Enum.filter(fn {{x, y}, _} -> x < width and y < height end)
    |> Enum.map(&create_spec(&1))
  end

  def is_mandelbrot({x, y}, {width, height}, {offx, offy} \\ @offset) do
    if(magnitude({x, y}) > 2.0 or x > width or y > height) do
      {false, 0}
    end

    ar = width / height
    a = (x + offx - width / 2.0) / width * 4.0 / @zoom
    b = (y + offy - height / 2.0) / height * 4.0 / ar / @zoom

    case @render_julia do
      true -> check_mandelbrot({a, b}, @julia_coord, 1)
      _ -> check_mandelbrot({a, b}, {a, b}, 1)
    end
  end

  def magnitude({a, b}) do
    :math.sqrt(a * a + b * b)
  end

  defp check_mandelbrot(point, orig, step) do
    _notes = """
          (x,y) = a+bi
          (a+bi)^2 = aa + 2abi - bb
      (aa-bb)+2abi
      x1,y1 = (aa-bb)+2abi

      f(n) = f(n-1) + c

      255 iterations
    """

    cond do
      magnitude(point) > 2.0 or step >= @step_size ->
        step

      magnitude(point) <= 2.0 and step >= @step_size ->
        step

      true ->
        point
        |> next_iter(orig)
        |> check_mandelbrot(orig, step + 1)
    end
  end

  def next_iter(point, orig) do
    {a, b} = point
    {oa, ob} = orig
    {a * a - b * b + oa, 2 * a * b + ob}
  end

  def plot_point(graph, {{x, y}, _steps}, {width, height})
      when x > width or
             y > height do
    graph
  end

  def plot_point(graph, {{x, y}, steps}, _screen) do
    ch = floor((@step_size - steps) / @step_size * 255)

    graph
    |> circle(1, fill: {ch, ch, ch}, translate: {x, y})
  end

  def create_spec({{x, y}, steps}) do
    ch = 255 - floor((steps - @clip_start) / (@step_size - @clip_start) * 255)
    circle_spec(1, fill: {ch, ch, ch}, translate: {x, y})
  end
end
