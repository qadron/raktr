require 'ap'
require_relative '../lib/raktr'

require_relative 'support/helpers/paths'
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
    next if f.include? '/servers/'
    require f
end

RSpec.configure do |config|
    config.color = true
    config.add_formatter :documentation
    config.filter_run_when_matching focus: true

    config.after(:all) do
        Servers.killall
    end
end
