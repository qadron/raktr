class EchoServer < Arachni::Reactor::Connection
    attr_reader :initialization_args

    def initialize( *args )
        @initialization_args = args
    end

    def on_data( data )
        send_data data
    end

end