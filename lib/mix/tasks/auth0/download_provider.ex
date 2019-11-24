defmodule Mix.Tasks.Auth0.DownloadProvider do
  use Mix.Task

  @shortdoc "Downloads the Auth0 Terraform Provider"
  def run(argv) do
    Application.ensure_all_started :inets
    Application.ensure_all_started :hackney
    version = Application.fetch_env!(:auth0_ex, :provider_version)
    platform = case find_platform() do
      { :error, message } ->
        IO.puts(message)
        exit({:error, 1})
      { :ok, platform } -> platform
    end
    path = "https://github.com/alexkappa/terraform-provider-auth0/releases/download/#{version}/"
    exe_name = "terraform-provider-auth0_#{version}"
    file_name = "#{exe_name}_#{platform}_amd64.tar.gz"
    default_destination = "~/.terraform.d/plugins/#{platform}_amd64"

    case argv do
      [] -> download(path, file_name, default_destination)
      [ destination | _ ] -> download(path, file_name, destination)
    end
    |> case do
         {:error, message} ->
           IO.puts(message)
         {:ok, %{source: source, destination: destination, file_name: file_name}} ->
           IO.puts("Auth0 Terraform provider successfully downloaded from #{source} and saved to #{destination}")
           untar(destination, file_name, exe_name)
           |> case do
                :ok -> IO.puts("Auth0 Terraform provider successfully extracted to #{Path.join(destination, exe_name)}")
               x -> IO.inspect(x)
              end
         x -> IO.inspect(x)
       end
  end

  defp untar(location, file_name, file_to_extract) do
    System.cmd("tar", ["-xvf", Path.join(location, file_name) |> Path.expand, file_to_extract])
    File.rename(file_to_extract, Path.join(location, file_to_extract) |> Path.expand)
  end

  defp find_platform() do
    supported_platforms = [:darwin]
    { _, type } = :os.type()
    cond do
      Enum.member?(supported_platforms, type) ->
        { :ok, Atom.to_string(type) }
      true ->
        { :error, "Unsupported platform, platform should be one of #{Enum.join(supported_platforms, ' ')}" }
    end
  end

  defp download(source, file_name, destination) do
    src = Path.join(source, file_name)
    dst = Path.join(destination, file_name) |> Path.expand
    case HTTPoison.get(src, [], follow_redirect: true) do
      { :ok, %HTTPoison.Response{ status_code: 200, body: body } } ->
        File.write!(dst, body)
      { :ok, %HTTPoison.Response{ status_code: 404} } ->
        { :error, "Not found: #{source}" }
      { :error, %HTTPoison.Error{ reason: reason } } ->
        { :error, reason }
    end
    |> case do
         :ok -> {:ok, %{source: source, destination: destination, file_name: file_name}}
         something -> something
       end
  end
end