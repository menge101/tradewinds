defmodule Mix.Tasks.Auth0.DownloadProvider do
  @moduledoc """
  This task automates the process of downloading the Auth0 Terraform provider.

  I don't use it, but one time I thought I might.
"""
  use Mix.Task

  @doc """
  This task is used to download the Auth0 terrafom provider.

  It is no longer used, but the functionality is still present.
"""
  @doc since: "0.1.0"
  @shortdoc "Downloads the Auth0 Terraform Provider"
  def run(argv) do
    Application.ensure_all_started :inets
    Application.ensure_all_started :hackney
    version = Application.fetch_env!(:auth0_ex, :provider_version)
    platform = get_platform()
    path = "https://github.com/alexkappa/terraform-provider-auth0/releases/download/#{version}/"
    exe_name = "terraform-provider-auth0_#{version}"
    file_name = "#{exe_name}_#{platform}_amd64.tar.gz"
    default_destination = "~/.terraform.d/plugins/#{platform}_amd64"

    destination = case argv do
      [] -> default_destination
      [destination | _] -> destination
    end

    case download(path, file_name, destination) do
      {:error, message} ->
        IO.puts(message)
      {:ok, %{source: source, destination: destination, file_name: file_name}} ->
        IO.puts("Auth0 Terraform provider successfully downloaded from #{source} and saved to #{destination}")
        untar(destination, file_name, exe_name)
        |> case do
             :ok -> IO.puts("Auth0 Terraform provider successfully extracted to #{Path.join(destination, exe_name)}")
             # credo:disable-for-next-line Credo.Check.Warning.IoInspect
             x -> IO.inspect(x)
           end
      # credo:disable-for-next-line Credo.Check.Warning.IoInspect
      x -> IO.inspect(x)
    end
  end

  @doc since: "0.1.0"
  @shortdoc "Function used to untar the downloaded Auth0 provider"
  defp untar(location, file_name, file_to_extract) do
    System.cmd("tar", ["-xvf", Path.join(location, file_name) |> Path.expand, file_to_extract])
    File.rename(file_to_extract, Path.join(location, file_to_extract) |> Path.expand)
  end

  @doc since: "0.1.0"
  @shortdoc "Function used to programmatically find what platform the caller is on"
  defp find_platform do
    supported_platforms = [:darwin]
    {_, type} = :os.type()
    if Enum.member?(supported_platforms, type) do
      {:ok, Atom.to_string(type)}
    else
      {:error, "Unsupported platform, platform should be one of #{Enum.join(supported_platforms, ' ')}"}
    end
  end

  @doc since: "0.1.0"
  @shortdoc "Function to handle the cases on the find_platform function, ad return a simple string when successful"
  defp get_platform do
    case find_platform() do
      {:error, message} ->
        IO.puts(message)
        exit({:error, 1})
      {:ok, platform} -> platform
    end
  end

  @doc since: "0.1.0"
  @shortdoc "Function to download a file fro the internet and store it locally"
  defp download(source, file_name, destination) do
    src = Path.join(source, file_name)
    dst = Path.join(destination, file_name) |> Path.expand
    case HTTPoison.get(src, [], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body }} -> File.write!(dst, body)
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, "Not found: #{source}"}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
    |> case do
         :ok -> {:ok, %{source: source, destination: destination, file_name: file_name}}
         something -> something
       end
  end
end
