# Vagrant Action.IO Provider

This is a [Vagrant](http://www.vagrantup.com/) 1.1+ plugin that adds an
[Action.IO](https://www.action.io/) provider to Vagrant, allowing Vagrant
to control and provision boxes in Action.IO.

## Features

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

Of course prior to doing this, you'll need to obtain an Action.IO-compatible
`.box` file for Vagrant.

## Quick Start

## Box Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `actionio` box format. You can view an example box in
the [example_box/ directory](https://github.com/action-io/vagrant-actionio/tree/master/example_box).
That directory also contains instructions on how to build a `.box` file.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

## Configuration

## Super User Access

Action.IO currently does not provide super-user access for free boxes.
This means that provisioner scripts that require `sudo` or `root` access
will not work for free boxes.

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

