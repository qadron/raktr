=begin

    This file is part of the Raktr project and may be subject to
    redistribution and commercial restrictions. Please see the Raktr
    web site for more information on licensing and terms of use.

=end

class Raktr
class Tasks

# {Base Task} which does not cancel itself once called and occurs at every
# tick.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Persistent < Base

    # Performs the task and marks it as {#done}.
    #
    # @return   [Object]
    #   Return value of the task.
    def call( *args )
        call_task( *args )
    end

end

end
end
