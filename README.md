# Travis Boxes

Travis Boxes is a set of tools that travis-ci.org team uses to create VM images/Vagrant boxes for
CI environment virtual machines.

[![Build Status](https://secure.travis-ci.org/travis-ci/travis-boxes.png)](http://travis-ci.org/travis-ci/travis-boxes)


## Getting started

First thing you need to do after clone is to create a new directory where base boxes will be kept:

    mkdir bases

then download the base box you want (in this case we will use 32-bit Ubuntu 11.04 box):

    cd bases && wget http://files.travis-ci.org/boxes/bases/natty32.box

Then create a separate gem set (often called Travis) on ruby 1.9 (1.9.3 is great), install Bundler and

    bundle install


## Building Boxes

Use the provided `thor` tasks to build worker base boxes, including uploading them to S3. They can then be distributed to the worker machines and used for updating the vms.

Base boxes are built per "environment" (i.e. worker type, e.g. "staging", "ruby", "rails", ...)

E.g. for rebuilding the staging base box use:

    $ thor travis:box:build -e ruby -b bases/natty32.box


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

Manually upload stuff to amazon s3

    brew install s3cmd
    s3cmd --configure
    s3cmd put [source] s3://travis-boxes/[target]

## License

travis-boxes is released under the MIT license.


## Copyright

2011, The Travis CI Team (contact@travis-ci.org)
