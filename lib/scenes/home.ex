defmodule ScenicTest.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort
  alias Scenic.Script

  import Scenic.Primitives
  # import Scenic.Components

  @text_size 24
  @step_size 1000
  @zoom_factor 0.4
  @zoom 4.0 * @zoom_factor
  @offset {0 * @zoom_factor, 0}
  @julia_coord {-0.8, -0.156}

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    # get the width and height of the viewport. This is to demonstrate creating
    # a transparent full-screen rectangle to catch user input
    {:ok, %ViewPort{size: {width, height}}} = ViewPort.info(scene.viewport)

    graph =
      Graph.build(font: :roboto, font_size: @text_size, clear_color: :grey)
      |> add_specs_to_graph([
        rect_spec({width, height})
      ])
      |> plot_mandelbrot({width, height})

    scene =
      scene
      |> assign(graph: graph)
      |> push_graph(graph)

    {:ok, scene}
  end

  defp plot_mandelbrot(graph, screen) do
    {width, height} = screen

    IO.inspect({"Start Computation: ", :calendar.local_time()})

    points =
      Enum.flat_map(0..width, fn x ->
        Enum.map(0..height, fn y -> {x, y} end)
      end)
      |> Enum.map(fn point -> {point, is_mandelbrot(point, screen)} end)

    IO.inspect({"End Computation: ", :calendar.local_time()})

    updated = List.foldr(points, graph, fn point, graph -> plot_point(graph, point, screen) end)
    IO.inspect({"End Rendering: ", :calendar.local_time()})
    updated
  end

  defp is_mandelbrot(point, screen) do
    {width, height} = screen
    {x, y} = point
    {offx, offy} = @offset
    ar = width / height
    a = (x + offx - width / 2.0) / width * 4.0 / @zoom
    b = (y + offy - height / 2.0) / height * 4.0 / ar / @zoom

    if(abs(a) > 2.0 or abs(b) > 0 or x > width or y > height) do
      {false, 0}
    end

    point = {a, b}
    # check_mandelbrot(point, point, 1)
    check_mandelbrot(point, @julia_coord, 1)
  end

  defp check_mandelbrot(point, orig, step) do
    {a, b} = point

    _notes = """
          (x,y) = a+bi
          (a+bi)^2 = aa + 2abi - bb
      (aa-bb)+2abi
      x1,y1 = (aa-bb)+2abi

      f(n) = f(n-1) + c

      255 iterations
    """

    if(abs(a) > 16.0 or abs(b) > 16.0 or step > @step_size) do
      {false, step}
    else
      if abs(a) <= 16.0 and abs(b) <= 16.0 and step >= @step_size do
        {true, step}
      else
        point
        |> next_iter(orig)
        |> check_mandelbrot(orig, step + 1)
      end
    end
  end

  defp next_iter(point, orig) do
    {a, b} = point
    {oa, ob} = orig
    {a * a - b * b + oa, 2 * a * b + ob}
  end

  defp plot_point(graph, data, view) do
    {point, {_mandelbrot, steps}} = data
    ch = floor((@step_size - steps) / @step_size * 255)

    {x, y} = point
    {width, height} = view

    if x > width or y > height do
      graph
    end

    graph
    |> circle(1, fill: {ch, ch, ch}, translate: point)
  end

  def handle_event(event, _from, scene) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, scene}
  end

  def handle_input(input, id, scene) do
    Logger.info("Received input: #{inspect(input)}")
    {:noreply, scene}
  end
end
