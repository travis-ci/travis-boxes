require 'travis/boxes'

describe Travis::Boxes::Config do
  let(:config) { Travis::Boxes::Config.new }

  describe 'defaults' do
    before :each do
      Travis::Boxes::Config.any_instance.stub(:read).and_return({})
    end

    it ':base defaults "natty32_new.box"' do
      config.test.base.should == 'natty32.box'
    end

    it ':cookbooks defaults to "vendor/travis-cookbooks"' do
      config.test.cookbooks.should == 'vendor/travis-cookbooks'
    end

    it ':json defaults to {}' do
      config.test.cookbooks.should == 'vendor/travis-cookbooks'
    end

    it ':recipes defaults to []' do
      config.test.cookbooks.should == 'vendor/travis-cookbooks'
    end
  end

  describe 'merging' do
    DATA_STUBS = {
      'local' => { 'base' => { 'secret' => 'secret' }, 'staging' => { 'another_secret' => 'another_secret' } },
      'base'  => { 'foo' => 'foo' },
      'active_definition' => { 'bar' => 'bar' }
    }

    before :each do
      config.stub(DATA_STUBS)
    end

    it 'merges base stuff' do
      config.staging.foo.should == 'foo'
    end

    it 'merges env stuff' do
      config.staging.bar.should == 'bar'
    end

    it 'merges local base stuff' do
      config.staging.secret.should == 'secret'
    end

    it 'merges local env stuff' do
      config.staging.another_secret.should == 'another_secret'
    end

    it 'adds the environment to the configuration' do
      config.staging.definition.should == 'staging'
    end
  end

  describe 'config file paths' do
    before :each do
      File.stub(:exists?).and_return(true)
    end

    it 'shared config/worker.base.yml' do
      config.send(:path, 'base').should == File.expand_path('../../config/worker.base.yml', __FILE__)
    end

    it 'shared config/worker.[environment].yml' do
      config.send(:path, 'staging').should == File.expand_path('../../config/worker.staging.yml', __FILE__)
    end

    it 'local config/worker.yml' do
      config.send(:path).should == './config/worker.yml'
    end
  end
end
