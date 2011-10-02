## Support for Travis CI worker box maintenance.

Use the provided `thor` tasks to build worker base boxes, including uploading them to S3. They can then be distributed to the worker machines and used for updating the vms.

Base boxes are built per "environment" (i.e. worker type, e.g. "staging", "ruby", "rails", ...)

E.g. for rebuilding the staging base box use:

    $ thor travis:box:build -e staging -b bases/lucid32.box

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
