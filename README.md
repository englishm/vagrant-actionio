# Vagrant Action.IO Provider (EXPERIMENTAL)

This is a [Vagrant](http://www.vagrantup.com/) 1.1+ plugin that adds an
[Action.IO](https://www.action.io/) provider to Vagrant, allowing Vagrant
to control and provision boxes in Action.IO.

## Features

* Create and boot Action.IO boxes with Vagrant.
* SSH into Action.IO boxes.
* Minimal synced folder support via `rsync`.
* ~~Provision the boxes with any built-in Vagrant provisioner~~ (Coming soon!)

## Usage

Install using standard Vagrant 1.1+ plugin installation methods. After
installing, `vagrant up` and specify the `actionio` provider. An example is
shown below.

```
$ vagrant plugin install vagrant-actionio
...
$ vagrant up --provider=actionio
...
```

## Quick Start

After installing Vagrant 1.1+ and the Action.IO vagrant provider, open
[Vagrant Settings](https://www.action.io/app#/vagrant) page on Action.IO
to generate an access token and an example `Vagrantfile`. Copy the contents
of the example `Vagrantfile` to your `Vagrantfile` and feel free to edit it
to specify your needs. Once done, run `vagrant up --provider=actionio`
to create a box on Action.IO.

## Box Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `actionio` box format. You can view an example box in
the [example_box/ directory](https://github.com/action-io/vagrant-actionio/tree/master/example_box).
That directory also contains instructions on how to build a `.box` file.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

## Configuration

The provider exposes a few provider-specific configuration options:

* `access_token` - The access token for accessing Action.IO API.
* `region` - Region to create Action.IO box in.
  * US West: `us-west-1`
  * US East: `us-west-1`
  * Europe: `eu-west-1`
  * South America: `sa-east-1`
  * South-East Asia: `ap-southeast-1`
  * Australia: `ap-southeast-2`
* `stack` - Name of the base stack.
  * Ruby, Rails: `rails`
  * Python, Django: `django`
  * Node.js: `nodejs`
  * Go: `go`

These can be set like typical provider-specific configuration:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "actionio-dummy"
  config.vm.box_url = "https://s3.amazonaws.com/vagrant-actionio/actionio-dummy.box"

  config.vm.provider :actionio do |aio|
    aio.access_token = "abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz01"
    aio.region = "us-west-1"
    aio.stack = "rails"
    aio.ssh_private_key_path = "~/.ssh/id_rsa"
  end
end
```

## Super User Access

Action.IO currently does not provide super-user access for free boxes.
This means that provisioner scripts that require `sudo` or `root` access
will not work for free boxes. Paid plans with super-user access is
coming soon.

## Networks

Networking features in the form of `config.vm.network` are not
supported with `vagrant-actionio`, currently. If any of these are
specified, Vagrant will emit a warning, but will otherwise boot
the Action.IO box.

## Synced Folders

There is minimal support for synced folders. Upon `vagrant up`,
`vagrant reload`, and `vagrant provision`, the Actin.IO provider
will use `rsync` (if available) to uni-directionally sync the folder
to the remote machine over SSH.

This is good enough for all built-in Vagrant provisioners (shell,
chef, and puppet) to work!

For bi-directional realtime syncing, please check out [Action.IO for Mac](https://www.action.io/mac).

## License

Copyright (c) 2013 Irrational Industries Inc. and Mitchell Hashimoto
This software is licensed under the [MIT License](https://raw.github.com/action-io/vagrant-actionio/master/LICENSE).

