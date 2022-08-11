defmodule ScenicTest.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph

  import Scenic.Primitives
  import ScenicTest.Scene.PreReq

  @size Application.get_env(:scenic_test, :viewport)[:size]
  @chunks Application.get_env(:scenic_test, :config)[:render_steps]
  @step_size Application.get_env(:scenic_test, :config)[:step_size]
  @clip_start Application.get_env(:scenic_test, :config)[:clip_start]
  @clip_end Application.get_env(:scenic_test, :config)[:clip_end]
  @graph Graph.build(font: :roboto, font_size: 24)
    |> add_specs_to_graph([rect_spec(@size)])
    |> text("0%", translate: {40, 40}, id: :progress_bar)

  @points compute_mandelbrot(@size)
      |> Enum.sort(fn {_, l_steps}, {_, r_steps} -> l_steps <= r_steps end)
      |> Enum.filter(fn {_, steps} ->
        steps >= @clip_start and steps <= @clip_end and steps <= @step_size
      end)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do

    graph =
      @graph

    points = 
      @points
      |> map_to_spec(@size)

    scene =
      scene
      |> assign(graph: graph, points: points, points_total: Enum.count(points), points_count: 0)
      |> push_graph(graph)

    send(self(),{:init})

    IO.inspect({"Starting: ",self()})
    {:ok, scene}
  end

  def handle_info(
        {:process, _id, primitives},
        %{assigns: %{graph: graph, points_total: total, points_count: count}} = scene
      ) do
    # IO.inspect({"Start: ",:calendar.local_time(), id})
    count = count + Enum.count(primitives)
    progress = count / total * 100.0

    graph =
      graph
      |> add_specs_to_graph(primitives)

    graph =
      cond do
        count == total -> Graph.delete(graph, :progress_bar)
        true -> Graph.modify(graph, :progress_bar, &text(&1, to_string(round(progress)) <> "%"))
      end

    scene =
      scene
      |> assign(graph: graph, points_count: count)
      |> push_graph(graph)

    # IO.inspect({"Ready: ",:calendar.local_time(), id, count + Enum.count(primitives), total })
    {:noreply, scene}
  end

  def handle_info({:init},%{assigns: %{points: points}} = scene) do

    count = ceil(Enum.count(points) / @chunks)

    points
    |> Enum.chunk_every(count)
    |> Enum.with_index(1)
    |> Enum.each(fn {primitives, idx} -> send(self(), {:process, idx, primitives}) end)
    {:noreply, scene}
  end
  def handle_info({:reset},scene) do
    graph =
      @graph
    scene =
      scene
      |> assign(graph: graph, points_count: 0)
      |> push_graph(graph)

    {:noreply, scene}
  end
end
