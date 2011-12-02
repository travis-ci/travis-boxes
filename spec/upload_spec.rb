# require 'travis/boxes'
#
# describe Travis::Boxes::Upload do
#   let :config do
#     Hashr.new(
#       :env => 'production',
#       :access_key_id => 'access_key_id',
#       :secret_access_key => 'secret_access_key'
#     )
#   end
#
#   let :upload do
#     Travis::Boxes::Upload.new('production', config)
#   end
#
#   before :each do
#     Time.stub(:now).and_return(Time.utc(2011, 11, 11))
#   end
#
#   it 'generates the target key from the given environment and the current timestamp' do
#     upload.send(:target).should == 'boxes/production/20111111000000.box'
#   end
# end
