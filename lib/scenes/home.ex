defmodule ScenicTest.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort
  alias Scenic.Script

  import Scenic.Primitives
  # import Scenic.Components

  @text_size 24
  @size Application.get_env(:scenic_test, :viewport)[:size]
  @step_size 64*2
  # @step_size 255
  @zoom_factor 0.25
  @zoom 4.0 * @zoom_factor
  @offset {0, 0}
  @julia_coord {-0.8, -0.156}
  @graph Graph.build(clear_color: :grey)
  |> add_specs_to_graph([rect_spec(@size)])

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    # get the width and height of the viewport. This is to demonstrate creating
    # a transparent full-screen rectangle to catch user input
    IO.inspect(@size)
    {width, height} = @size

    graph =
      @graph
      # |> plot_mandelbrot({width, height})

    scene =
      scene
      |> assign(graph: graph)
      |> push_graph(graph)
      
    IO.inspect(self())
    plot_mandelbrot(@size)
    {:ok, scene}
  end
  
  defp process_block(_pos,{_,0}) do
  end

  defp process_block(_pos,{0,_}) do
  end

  defp process_block({x,y} = pos, {1,1}) do
    {_,steps} = is_mandelbrot(pos,@size)
    ch = floor((@step_size - steps) / @step_size * 255)
    # IO.puts("Plotting: #{x},#{y}")
    GenServer.cast(self(),{:plot,pos,ch})
    # graph
    # |> circle(1, fill: {ch,ch,ch}, translate: pos)
  end

  defp process_block({x,y}, {width,height}) do
    midx = div(width,2)
    midy = div(height,2)
    # IO.puts("Spawning: #{inspect pos},#{inspect dim}")
    process_block({x,y},{midx,midy})
    process_block({x+midx,y},{width-midx,midy})
    process_block({x,y+midy},{midx,height-midy})
    process_block({x+midx,y+midy},{width-midx,height-midy})
  end

  def plot_mandelbrot(screen) do
    # {width, height} = screen

    IO.inspect({"Start Computation: ", :calendar.local_time()})

    # points =
    #   Enum.flat_map(0..width, fn x ->
    #     Enum.map(0..height, fn y -> {x, y} end)
    #   end)
    #   |> Enum.map(fn point -> {point, is_mandelbrot(point, screen)} end)

    IO.inspect({"End Computation: ", :calendar.local_time()})

    #updated = List.foldr(points, graph, fn point, graph -> plot_point(graph, point, screen) end)
    # updated = plot(graph,points,screen)
    process_block({0,0},@size)
    IO.inspect({"End Rendering: ", :calendar.local_time()})
  end
  
  defp plot(graph,[],_view), do: graph
  
  defp plot(graph,[head|tail],view) do 
    graph 
    |> plot_point(head,view)
    |> plot(tail,view)
  end

  defp is_mandelbrot(point, screen) do
    {width, height} = screen
    {x, y} = point
    {offx, offy} = @offset
    ar = width / height
    a = (x + offx - width / 2.0) / width * 4.0 / @zoom
    b = (y + offy - height / 2.0) / height * 4.0 / ar / @zoom

    if(magnitude(point) > 2.0 or x > width or y > height) do
      {false, 0}
    end

    point = {a, b}
    #check_mandelbrot(point, point, 1)
    check_mandelbrot(point, @julia_coord, 1)
  end

  defp magnitude({a, b}) do
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
  
  def handle_cast({:process,pos,dim} = msg, scene) do
    # IO.inspect msg
    process_block(pos,dim)
    {:noreply, scene, :hibernate}
  end
  def handle_cast({:plot,point,ch} = msg,%{assigns: %{graph: graph}} = scene) do
    # IO.inspect msg
    graph = 
      graph
      |> circle(1, fill: {ch,ch,ch}, translate: point)
    scene = 
      scene
      |> assign(graph: graph)
      |> push_graph(graph)
    {:noreply, scene, :hibernate}
  end
  
  def handle_cast(msg, scene) do
    IO.puts("Received MSG: #{inspect msg}")
    {:noreply, scene}
  end

end
