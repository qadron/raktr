=begin

    This file is part of the Raktr project and may be subject to
    redistribution and commercial restrictions. Please see the Raktr
    web site for more information on licensing and terms of use.

=end

Gem::Specification.new do |s|
    require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/raktr/version'

    s.name              = 'raktr'
    s.license           = 'BSD 3-Clause'
    s.version           = Raktr::VERSION
    s.date              = Time.now.strftime('%Y-%m-%d')
    s.summary           = 'A pure-Ruby implementation of the Reactor pattern.'
    s.homepage          = 'https://github.com/qadron/raktr'
    s.email             = 'tasos.laskos@gmail.com'
    s.authors           = [ 'Tasos Laskos' ]

    s.files             = %w(README.md Rakefile LICENSE.md CHANGELOG.md)
    s.files            += Dir.glob('lib/**/**')
    s.test_files        = Dir.glob('spec/**/**')

    s.extra_rdoc_files  = %w(README.md LICENSE.md CHANGELOG.md)
    s.rdoc_options      = ['--charset=UTF-8']

    s.description = <<description
    Raktr is a simple, lightweight, pure-Ruby implementation of the Reactor
    pattern, mainly focused on network connections -- and less so on generic tasks.
description

end
