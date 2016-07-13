use Mix.Config

config :relisa,
  targets: [
    # Targets are specified with an {address, ssh_key_path} tuple
    # set ssh_key_path to nil to use a running SSH agent
    # {"ubuntu@54.68.138.247", "/vagrant/deploy.pem"}
  ],
  hooks: [
    # Hooks are Mix tasks that will be executed at certain life-cycle moments
    # in Relisa
    # pre: ["phoenix.digest"]
  ]
