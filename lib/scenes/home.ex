defmodule ScenicTest.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph

  import Scenic.Primitives

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
    GenServer.cast(self(),{:plot,pos,ch})
    # graph
    # |> circle(1, fill: {ch,ch,ch}, translate: pos)
  end

  defp process_block({x,y}, {width,height}) do
    midx = div(width,2)
    midy = div(height,2)
    GenServer.cast(self(),{:process,{x,y},{midx,midy}})
    GenServer.cast(self(),{:process,{x+midx,y},{width-midx,midy}})
    GenServer.cast(self(),{:process,{x,y+midy},{midx,height-midy}})
    GenServer.cast(self(),{:process,{x+midx,y+midy},{width-midx,height-midy}})
  end

  def plot_mandelbrot(screen) do
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

  defp is_mandelbrot({x,y}, screen) do
    {width, height} = screen
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
    process_block(pos,dim)
    {:noreply, scene}
  end
  
  def handle_cast(:finish, %{assigns: %{graph: graph}} = scene) do
    IO.inspect({"DONE", :calendar.local_time()})
    scene =
      scene
      |> push_graph(graph)
    {:noreply,scene}
  end

  def handle_cast({:plot,{x,y} = point,ch} = msg,%{assigns: %{graph: graph}} = scene) do
    graph = 
      graph
      |> circle(1, fill: {ch,ch,ch}, translate: point)
    scene = 
      scene
      |> assign(graph: graph)
      # |> push_graph(graph)
    if {x + 1,y + 1} == @size do
      GenServer.cast(self(),:finish)
    end
    {:noreply, scene}
  end
  
  def handle_cast(msg, scene) do
    IO.puts("Received MSG: #{inspect msg}")
    {:noreply, scene}
  end

end
