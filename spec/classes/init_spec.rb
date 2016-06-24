require 'spec_helper'
describe 'haproxywp' do

  context 'with defaults for all parameters' do
    it { should contain_class('haproxywp') }
  end
end
