
=begin

    This file is part of the Raktr project and may be subject to
    redistribution and commercial restrictions. Please see the Raktr
    web site for more information on licensing and terms of use.

=end

class Raktr

# @note Pretty much an `EventMachine::Queue` rip-off.
#
# A cross thread, {Raktr#schedule Raktr scheduled}, linear queue.
#
# This class provides a simple queue abstraction on top of the
# {Raktr#schedule scheduler}.
#
# It services two primary purposes:
#
# * API sugar for stateful protocols.
# * Pushing processing onto the {Raktr#thread reactor thread}.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Queue

    # @return   [Raktr]
    attr_reader :raktr

    # @param    [Reactor]   reactor
    def initialize( reactor )
        @raktr = reactor
        @items   = []
        @waiting = []
    end

    # @param    [Block] block
    #   Block to be {Reactor#schedule scheduled} by the {Reactor} and passed
    #   an item from the queue as soon as one becomes available.
    def pop( &block )
        @raktr.schedule do
            if @items.empty?
                @waiting << block
            else
                block.call @items.shift
            end
        end

        nil
    end

    # @param    [Object] item
    #   {Reactor#schedule Schedules} an item for addition to the queue.
    def push( item )
        @raktr.schedule do
            @items.push( item )
            @waiting.shift.call @items.shift until @items.empty? || @waiting.empty?
        end

        nil
    end
    alias :<< :push

    # @note This is a peek, it's not thread safe, and may only tend toward accuracy.
    #
    # @return [Boolean]
    def empty?
        @items.empty?
    end

    # @note This is a peek, it's not thread safe, and may only tend toward accuracy.
    #
    # @return [Integer]
    #   Queue size.
    def size
        @items.size
    end

    # @note Accuracy cannot be guaranteed.
    #
    # @return [Integer]
    #   Number of jobs that are currently waiting on the Queue for items to appear.
    def num_waiting
        @waiting.size
    end

end

end
