defmodule DemoWeb.Live.HomeLive do
  use DemoWeb, :live_view

  alias Demo.StyleTransfer
  alias Membrane.WebRTC.Live.{Capture, Player}

  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        Task.start_link(fn ->
          Boombox.run(
            input: {:webrtc, },
            output: {:webrtc, }
          )
        end)

        socket
        |> Capture.attach(
          id: ,
          signaling: ,
          audio?: false,
          video?: true,
          preview?: false
        )
        |> Player.attach(
          id: ,
          signaling:
        )
      else
        socket
      end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Capture.live_render socket={@socket}  />
    <Player.live_render socket={@socket}  />
    """
  end
end
