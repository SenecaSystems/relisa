Relisa
======

![Lisa Simpson](https://s3-us-west-2.amazonaws.com/seneca-systems-uploads/lisa-mapple.jpg)

Fast, simple, and composable deployment library for Elixir.

## Installation

Just add `relisa` to your project dependencies:

```elixir
def deps do
  [{:relisa, "~> 0.1.0"}]
end
```

### Configuration

To get started, run `mix relisa.init` in the root directory of your project.

![init](https://cloud.githubusercontent.com/assets/1015847/8770260/dfb3f2de-2e62-11e5-9e9d-8b7032c44700.png)

This will create a `config/relisa.exs` file for all of your relisa-specific configuration.
Here is an example of what one looks like:

```elixir
use Mix.Config

config :relisa,
  # Targets are specified with an {address, ssh_key_path} tuple
  # set ssh_key_path to nil to use a running SSH agent
  targets: [
    {"ubuntu@54.68.138.247", "/vagrant/deploy.pem"}
  ],

  # Hooks are Mix tasks that will be executed at certain life-cycle moments
  # in Relisa
  hooks: [

    pre: ["phoenix.digest"]
  ]
```

Relisa uses [ssh](https://en.wikipedia.org/wiki/Secure_Shell) and [scp](https://en.wikipedia.org/wiki/Secure_Copy) to connect with your servers. Each `target` should specify an address (`username@ip_address_or_hostname`) and the path to an ssh key for that server.


## Usage


### Prepare a release

To ready your application for production, simply run `mix relisa.prepare`. Relisa prefers [Semantic Versioning](http://semver.org/) and you can include the `--major`, `--minor`, or `--patch` flags to specify how your version should be bumped. The default is `--patch`.

![major prepare](https://cloud.githubusercontent.com/assets/1015847/8770265/fdb7ea56-2e62-11e5-9dc4-5409b9914f77.png)

Since Relisa automatically updates your version for you, you should commit the changes.

### Deploy release

All you have to do is `MIX_ENV=prod mix relisa.deploy` and relax. Relisa will run any hooks before deploying, package up your release, transport it to each of the `targets` specified in your configuration, and start the application.

Note that you need to do this step on the same arch as your target. We use [Vagrant](https://www.vagrantup.com) to make this a snap. See [this gist](https://gist.github.com/ndemonner/56df80cd3a09b9c0ad7f) for the `Vagrantfile` we use.

![deploy](https://cloud.githubusercontent.com/assets/1015847/8770266/03884570-2e63-11e5-9544-24b0120da58b.png)

### Upgrade

If Relisa detects that your application is already running, it will update the running application to the latest version. This utilizes hot-code reloading for zero-downtime deployments and upgrades.

![upgrade a running app](https://cloud.githubusercontent.com/assets/1015847/8770270/0fbe3c64-2e63-11e5-9719-9921731a70b4.png)

### Rollback

If your deployment had a bug and you'd like to roll back, that's not a problem. `mix relisa.rollback 1.0.0` (where `1.0.0` is the version you'd like to roll back to) and you're good to go.

![rolling back a deploy](https://cloud.githubusercontent.com/assets/1015847/8770371/41376994-2e65-11e5-8370-b62b085eb25f.png)

## Hooks

Relisa is meant to be incredibly light-weight so you only load the tools you need. It can run mix tasks before a deployment as specified in the `:hooks` configuration option. From digesting assets to commiting and pushing version changes, Relisa is incredibly extendable.
