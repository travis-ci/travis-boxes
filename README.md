## [Deprecated] This repo is not currently maintained. We are in the process of figuring out better tooling for building VMs.

# Travis Boxes

Travis Boxes is a set of tools that travis-ci.org team uses to create VM images/Vagrant boxes for CI environment virtual machines.

[![Build Status](https://secure.travis-ci.org/travis-ci/travis-boxes.png)](http://travis-ci.org/travis-ci/travis-boxes)

## Getting Started

Apart from running `bundle install`, also run

    $ thor travis:init

This will create a blank `config/worker.yml`, please read 'Box Customization' for more info.

## Chef Cookbooks location

We use [OpsCode Chef](http://www.opscode.com/chef/) to provision VMs (and everything else). travis-boxes assumes [travis-cookbooks](https://github.com/travis-ci/travis-cookbooks) are
located one directory up, like this:

    travis-boxes
    travis-cookbooks


## Building Boxes

Use the provided `thor` tasks to build VirtualBox base boxes and worker boxes, including uploading them to S3. They can then be distributed to the worker machines and used for updating the vms.

Worker boxes are built per "environment" (i.e. worker type, e.g. "staging", "ruby", "rails", ...)

E.g. for rebuilding the staging base box use:

    $ thor travis:box:build staging

You can also use the `thor` tasks to build a new base box which the worker boxes are provisioned on top of.

    $ thor travis:base:build

## Box Customization

Configuration for the boxes is in the local and shared `config/*.yml` files.

The shared file `config/worker.base.yml` will be used for configuration common to all boxes and it will be merged with the shared file `config/[environment].yml`.

The result is then also merged with

* the "base" section from the local file `config/worker.yml`
* the respective environment section (e.g. "staging") from the local file `config/worker.yml`

The file `config/worker.yml` is meant to be *local* and should not be checked in.

Example:

    # config/worker.base.yml (in travis-boxes)
    foo: foo

    # config/worker.staging.yml (in travis-boxes)
    bar: bar

    # config/worker.yml (in the current working directory)
    base:
      secret: secret
    staging:
      another_secret: another_secret

    # Travis::Boxes::Config.new.staging
    {
      'foo' => 'Foo',
      'bar' => 'bar',
      'secret' => 'secret',
      'another_secret' => 'another_secret',
    }

## The Standard box

Because different language/technology VM setups overlap, we first build the standard box that only has, for example, 1 Ruby, 1 Python and 1 Node.js version and then provision VM-specific tools on top of that by modifying Chef node attributes in host machine specific worker.yml.


## Uploading boxes

To upload a base box you can use:

    thor travis:base:upload

This will upload the natty32.box by default. You can use -d to specify a different base box definition to upload.

To upload a provisioned box you can use:

    thor travis:box:upload

This will upload the travis-staging.box by default, renaming it to staging/[yyyy-mm-dd-hhmm].box during the upload process. If you want to upload a different provisioned box you can use the -d option, for example:

    thor travis:box:upload standard
    thor travis:box:upload ruby

If you need access to files.travis-ci.org, pass your SSH key to [@michaelklishin](https://github.com/michaelklishin)


## License

travis-boxes is released under the MIT license.


## Copyright

2011-2012, The Travis CI Team (contact@travis-ci.org)
