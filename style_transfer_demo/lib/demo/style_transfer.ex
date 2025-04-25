defmodule Demo.StyleTransfer do
  @moduledoc false
  @styles [:candy, :kaganawa, :mosaic, :picasso, :princess, :udnie, :vangogh]

  @spec load_model(atom()) :: Ortex.Model.t()
  def load_model(style) when style in @styles do
    model_path =
      Application.get_application(__MODULE__)
      |> :code.priv_dir()
      |> Path.join("ai_models/#{style}.onnx")

    Ortex.load(model_path)
  end

  @spec apply(Image.t(), Ortex.Model.t()) :: Image.t()
  def apply(image, model) do
    image
    |> preprocess()
    |> predict(model)
    |> postprocess()
  end

  defp predict(tensor, model) do
    offsets = Nx.tensor([1.0, 1.0, 1.0, 1.0], type: :f32)
    {output} = Ortex.run(model, {tensor, offsets})
    output
  end

  defp preprocess(image) do
    image
    |> Image.to_nx!()
    |> Nx.backend_transfer(EXLA.Backend)
    |> Nx.as_type(:f32)
    |> Nx.transpose(axes: [2, 0, 1])
    |> Nx.reshape({1, 3, Image.height(image), Image.width(image)})
  end

  defp postprocess(tensor) do
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
