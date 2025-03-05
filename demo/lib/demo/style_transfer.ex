defmodule Demo.StyleTransfer do

  @styles [:candy, :kaganawa, :mosaic, :mosaic_mobile, :picasso, :princess, :udnie, :vangogh]

  def load_model(style) when style in @styles do
    style
    |> get_model_path()
    |> Ortex.load()
  end


  def predict(tensor, model) do
    offsets = Nx.tensor([1.0, 1.0, 1.0, 1.0], type: :f32)
    {output} = Ortex.run(model, {tensor, offsets})
    output
  end

  defp get_model_path(style) do
    Application.get_application(__MODULE__)
    |> :code.priv_dir()
    |> Path.join("ai_models/#{style}.onnx")
  end

  def preprocess(image) do
    image
    |> Image.to_nx!()
    |> Nx.backend_transfer(EXLA.Backend)
    |> Nx.as_type(:f32)
    |> Nx.transpose(axes: [2, 0, 1])
    |> Nx.reshape({1, 3, Image.height(image), Image.width(image)})
  end

  def postprocess(tensor) do
    {1, 3, height, width} = Nx.shape(tensor)

    tensor
    |> Nx.backend_transfer(EXLA.Backend)
    |> Nx.reshape({3, height, width}, names: [:colours, :height, :width])
    |> Nx.transpose(axes: [1, 2, 0])
    |> Nx.max(0.0)
    |> Nx.min(255.0)
    |> Nx.round()
    |> Nx.as_type(:u8)
    |> Image.from_nx!()
  end
end
