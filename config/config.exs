# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Configure the main viewport for the Scenic application
config :scenic_test, :viewport, %{
  name: :main_viewport,
  size: {300, 200},
  default_scene: {ScenicTest.Scene.Home, nil},
  drivers: [
    %{
      module: Scenic.Driver.Local,
      name: :local,
      window: [resizeable: false, title: "scenic_test"]
    }
  ]
}

config :scenic, :assets, module: ScenicTest.Assets

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
