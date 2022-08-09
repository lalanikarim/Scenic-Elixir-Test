defmodule ScenicTest.Scenic.PreReq do
  import Scenic.Primitives

  @step_size 64*2
  @zoom_factor 0.25
  @zoom 4.0 * @zoom_factor
  @offset {0, 0}
  @julia_coord {-0.8, -0.156}
  
  def plot_mandelbrot(graph,{width,height} = screen) do
    points =
      Enum.flat_map(0..width, fn x ->
        Enum.map(0..height, fn y -> {x, y} end)
      end)
      |> Enum.map(fn point -> {point, is_mandelbrot(point, screen)} end)

    IO.inspect({"Start Composition: ", :calendar.local_time()})
    updated = List.foldr(points, graph, fn point, graph -> plot_point(graph, point, screen) end)
    IO.inspect({"End Composition: ", :calendar.local_time()})

    updated
  end

  def is_mandelbrot({x,y}, {width,height}) do
    if(magnitude({x,y}) > 2.0 or x > width or y > height) do
      {false, 0}
    end

    {offx, offy} = @offset
    ar = width / height
    a = (x + offx - width / 2.0) / width * 4.0 / @zoom
    b = (y + offy - height / 2.0) / height * 4.0 / ar / @zoom

    #check_mandelbrot(point, point, 1)
    check_mandelbrot({a,b}, @julia_coord, 1)
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

    if magnitude(point) > 2.0 or step > @step_size do
      {false, step}
    else
      if magnitude(point) <= 2.0 and step >= @step_size do
        {true, step}
      else
        point
        |> next_iter(orig)
        |> check_mandelbrot(orig, step + 1)
      end
    end
  end

  def next_iter(point, orig) do
    {a, b} = point
    {oa, ob} = orig
    {a * a - b * b + oa, 2 * a * b + ob}
  end

  def plot_point(graph, {{x,y}, {_mandelbrot, steps}}, {width, height}) do
    ch = floor((@step_size - steps) / @step_size * 255)

    if x > width or y > height do
      graph
    end

    graph
    |> circle(1, fill: {ch, ch, ch}, translate: {x,y})
  end
end

defmodule ScenicTest.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph

  import Scenic.Primitives
  import ScenicTest.Scenic.PreReq

  @size Application.get_env(:scenic_test, :viewport)[:size]
  @step_size 64*2
  @graph Graph.build(clear_color: :grey)
    |> add_specs_to_graph([rect_spec(@size)])
    |> plot_mandelbrot(@size)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do

    graph =
      @graph

    scene =
      scene
      |> assign(graph: graph)
      |> push_graph(graph)

    {:ok, scene}
  end
end
