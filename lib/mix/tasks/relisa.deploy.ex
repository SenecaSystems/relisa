defmodule Mix.Tasks.Relisa.Deploy do
  use Mix.Task

  @shortdoc "Packages and deploys an OTP release"

  @moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(_args) do
    Relisa.line_break
    run_pre_hooks
    package_release
    install_release
    Relisa.say "All done!"
    Relisa.line_break
  end

  defp run_pre_hooks do
    hooks = Application.get_env(:relisa, :hooks)
    if hooks[:pre] do
      Relisa.say "Running `pre` hooks"
      Enum.each hooks[:pre], fn (hook) ->
        Relisa.subsay hook
        Mix.Task.run hook
      end
    else
      Relisa.say "Skipping `pre` hooks (none registered)"
    end
  end

  defp package_release do
    Relisa.say "Processing #{config[:version]} release"
    Relisa.subsay "Packaging release with exrm"
    Mix.Task.run "release"
  end

  defp install_release do
    Relisa.say("Installing release to targets")
    Enum.each targets, fn ({host, key}) ->
      if needs_upgrade?(host, key) do
        perform_upgrade host, key
      else
        deploy_release host, key
      end
    end
  end

  defp deploy_release(host, key) do
    Relisa.subsay "#{host}: Ensuring deploy path exists"
    Mix.Shell.IO.cmd "ssh #{host} #{key_parameter(key)} -oStrictHostKeyChecking=no \"mkdir -p #{deploy_path}\""
    Relisa.subsay "#{host}: Moving release to deploy path"
    Mix.Shell.IO.cmd "scp #{key_parameter(key)} #{release_path} #{host}:#{deploy_path}"
    Relisa.subsay "#{host}: Decompressing release archive"
    Mix.Shell.IO.cmd "ssh #{host} #{key_parameter(key)} \"tar -xf #{deploy_path}/#{archive_name} -C #{deploy_path}\""
    Relisa.subsay "#{host}: Starting app"
    Mix.Shell.IO.cmd "ssh #{host} #{key_parameter(key)} \"sudo #{deploy_path}/bin/#{config[:app]} start\""
  end

  defp needs_upgrade?(host, key) do
    result = Mix.Shell.IO.cmd "ssh #{host} #{key_parameter(key)} -oStrictHostKeyChecking=no \"[ -d #{deploy_path}/releases ]\""
    result == 0
  end

  defp perform_upgrade(host, key) do
    Relisa.subsay "#{host}: Creating release directory for #{config[:version]}"
    Mix.Shell.IO.cmd "ssh #{host} #{key_parameter(key)} \"mkdir -p #{deploy_path}/releases/#{config[:version]}\""
    Relisa.subsay "#{host}: Moving archive to release path"
    Mix.Shell.IO.cmd "scp #{key_parameter(key)} #{release_path} #{host}:#{deploy_path}/releases/#{config[:version]}"
    Relisa.subsay "#{host}: Upgrading `#{config[:app]}` to #{config[:version]}"
    Mix.Shell.IO.cmd "ssh #{host} #{key_parameter(key)} \"sudo #{deploy_path}/bin/#{config[:app]} upgrade '#{config[:version]}'\""
  end

  defp config do
    Mix.Project.config()
  end

  defp targets do
    Application.get_env(:relisa, :targets)
  end

  defp archive_name do
    "#{config[:app]}.tar.gz"
  end

  defp release_path do
    "rel/#{config[:app]}/releases/#{config[:version]}/#{archive_name}"
  end

  defp deploy_path do
    "~/#{config[:app]}"
  end

  defp key_parameter(_key=nil) do
    ""
  end

  defp key_parameter(key) do
    "-i#{key}"
  end
end
