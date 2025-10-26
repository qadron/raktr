require 'raktr'

host = '127.0.0.1'
port = 7331

class EchoServer < Raktr::Connection
    include TLS

    def initialize( append, options = {} )
        @append = append
    end

    def on_connect
        start_tls
    end

    def on_read( data )
        with_echo = "#{data} #{@append}"

        puts "Server - Echoing: #{with_echo}"
        write with_echo
    end

end

class EchoClient < Raktr::Connection
    include TLS

    def initialize( message, options = {} )
        @tls =  options[:tls]
        @message = message
    end

    def on_connect
        start_tls

        puts "Client - Sending: #{@message}"
        write @message
    end

    def on_read( data )
        puts "Client - Got: #{data}"
        @raktr.stop
    end
end

Raktr do |r|

    r.listen host, port, EchoServer, '(world, world, world...)',
        tls: {
            ca:          '/home/zapotek/workspace/qadron/raktr/spec/support/fixtures/pems/ca-cert.pem',
            certificate: '/home/zapotek/workspace/qadron/raktr/spec/support/fixtures/pems/server/cert.pem',
            public_key:  '/home/zapotek/workspace/qadron/raktr/spec/support/fixtures/pems/server/pub.pem',
            private_key: '/home/zapotek/workspace/qadron/raktr/spec/support/fixtures/pems/server/key.pem'
        }
    r.connect host, port, EchoClient, 'Hello world!',
          tls: {
            ca:          '/home/zapotek/workspace/qadron/raktr/spec/support/fixtures/pems/ca-cert.pem',
            certificate: '/home/zapotek/workspace/qadron/raktr/spec/support/fixtures/pems/client/cert.pem',
            public_key:  '/home/zapotek/workspace/qadron/raktr/spec/support/fixtures/pems/client/pub.pem',
            private_key: '/home/zapotek/workspace/qadron/raktr/spec/support/fixtures/pems/client/key.pem'
          }

end
