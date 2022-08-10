defmodule ScenicTest.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph

  import Scenic.Primitives
  import ScenicTest.Scenic.PreReq

  @size Application.get_env(:scenic_test, :viewport)[:size]
  @chunks Application.get_env(:scenic_test, :config)[:render_steps]
  @graph Graph.build()
    |> add_specs_to_graph([rect_spec(@size)])

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do

    points = compute_mandelbrot(@size)

    count = ceil(Enum.count(points)/@chunks)
    points 
    |> map_to_spec(@size)
    |> Enum.shuffle()
    |> Enum.chunk_every(count) # to get @chunks number of chunks
    |> Enum.with_index(1)
    |> Enum.each(fn {primitives,idx} -> send(self(),{:process,idx,primitives}) end)

    graph = 
      @graph

    scene =
      scene
      |> assign(graph: graph,points_total: Enum.count(points),points_count: 0)
      |> push_graph(graph)

    {:ok, scene}
  end

  def handle_info({:process,id,primitives}, %{assigns: %{graph: graph, points_total: total, points_count: count}} = scene) do
    IO.inspect({"Start: ",:calendar.local_time(), id})
    graph =
      graph
      |> add_specs_to_graph(primitives)
    scene =
      scene 
      |> assign(graph: graph, points_count: count + Enum.count(primitives))
      |> push_graph(graph)
      IO.inspect({"Ready: ",:calendar.local_time(), id, count + Enum.count(primitives), total })
    {:noreply, scene}
  end

end
