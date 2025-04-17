defmodule DemoWeb.Live.WorkingLive do
  use DemoWeb, :live_view

  alias Demo.StyleTransfer

  alias Membrane.WebRTC.Live.Capture
  alias Membrane.WebRTC.Live.Player

  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        ingress_signaling = Membrane.WebRTC.Signaling.new()
        egress_signaling = Membrane.WebRTC.Signaling.new()

        {:ok, _task_pid} =
          Task.start_link(fn ->
            model = StyleTransfer.load_model(:picasso)

            Boombox.run(
              input: {:webrtc, ingress_signaling},
              output: {:stream, video: :image, audio: false, video_width: 400}
            )
            |> Stream.map(fn %Boombox.Packet{kind: :video} = packet ->
              image = StyleTransfer.apply(packet.payload, model)
              %{packet | payload: image}
            end)
            |> Boombox.run(
              input: {:stream, video: :image, audio: false},
              output: {:webrtc, egress_signaling}
            )
          end)

        socket
        |> Capture.attach(
          id: "mediaCapture",
          signaling: ingress_signaling,
          audio?: false,
          video?: true,
          preview?: false
        )
        |> Player.attach(
          id: "videoPlayer",
          signaling: egress_signaling
        )
      else
        socket
      end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h3>Captured stream preview</h3>
    <Capture.live_render socket={@socket} capture_id="mediaCapture" />

    <h3>Stream sent by the server</h3>
    <Player.live_render socket={@socket} player_id="videoPlayer" />
    """
  end
end
