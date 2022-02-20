require 'spec_helper'

describe Raktr::Tasks::Base do
    it_should_behave_like 'Raktr::Tasks::Base'

    subject { described_class.new{} }
end

