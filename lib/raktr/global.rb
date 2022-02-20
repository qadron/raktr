=begin

    This file is part of the Raktr project and may be subject to
    redistribution and commercial restrictions. Please see the Raktr
    web site for more information on licensing and terms of use.

=end

require 'singleton'

class Raktr

# **Do not use directly!**
#
# Use the {Reactor} class methods to manage a globally accessible {Reactor}
# instance.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
# @private
class Global < Raktr
    include Singleton
end

end
