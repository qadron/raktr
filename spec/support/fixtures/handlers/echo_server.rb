class EchoServer < Raktr::Connection
    attr_reader :initialization_args

    def initialize( *args )
        @initialization_args = args
    end

    def on_read( data )
        write data
    end

end
