# Style Transfer Demo

Gets the WebRTC video stream from the browser, applies a style transfer filter on it and sends it back to the browser via WebRTC.

Uses Boombox, Phoenix LiveView and Ortex.

The most imporant parts of this demo is `style_transfer_demo/lib/demo_web/live/home_live.ex`.

Style transfer implementation is in `style_transfer_demo/lib/demo/style_transfer.ex`.

JS file that creates necessary LiveView hooks is `style_transfer_demo/assets/js/app.js`.

## Run

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
