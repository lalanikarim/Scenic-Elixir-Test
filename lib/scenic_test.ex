defmodule ScenicTest do
  import Supervisor.Spec, warn: false

  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:scenic_test, :viewport)

    # start the application with the viewport
    children = [
      # supervisor(Scenic, [viewports: [main_viewport_config]])
      %{id: Scenic, start: {Scenic, :start_link, [[main_viewport_config]]}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
