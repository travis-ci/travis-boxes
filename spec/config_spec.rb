require 'travis/boxes'

describe Travis::Boxes::Config do
  let :config do
    Travis::Boxes::Config.new('test')
  end

  describe 'defaults' do
    before :each do
      Travis::Boxes::Config.any_instance.stub(:read).and_return({})
    end

    it ':base defaults "lucid32_new.box"' do
      config.base.should == 'lucid32_new.box'
    end

    it ':cookbooks defaults to "vendor/travis-cookbooks"' do
      config.cookbooks.should == 'vendor/travis-cookbooks'
    end

    it ':json defaults to {}' do
      config.cookbooks.should == 'vendor/travis-cookbooks'
    end

    it ':recipes defaults to []' do
      config.cookbooks.should == 'vendor/travis-cookbooks'
    end
  end
end
