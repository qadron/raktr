shared_examples_for 'Arachni::Reactor' do
    after(:each) do
        @socket.close if @socket
        @socket = nil

        next if !@reactor

        if @reactor.running?
            @reactor.stop
            @reactor.block
        end

        @reactor = nil
    end

    klass = Arachni::Reactor

    subject { @reactor ||= klass.new }
    let(:reactor) { subject }
    let(:data) { ('blah' * 999999) + "\n\n" }

    describe '.global' do
        it 'returns a Reactor' do
            klass.global.should be_kind_of klass
        end

        it 'caches the instance' do
            global = klass.global
            klass.global.should == global
        end
    end

    describe '.stop' do
        it 'stops the global reactor' do
            global = klass.global
            klass.global.run_in_thread
            klass.stop

            global.block
        end

        it 'destroys the global instance' do
            global = klass.global
            klass.stop

            klass.object_id.should_not == global.object_id
        end
    end

    describe '#initialize' do
        describe :max_tick_interval do
            it 'sets the maximum amount of time for each loop interval'
        end
    end

    describe '#create_queue' do
        let(:queue) { subject.create_queue }

        it 'creates a new queue' do
            queue.should be_kind_of klass::Queue
        end

        it 'assigns this reactor as the scheduler' do
            queue.reactor.should == subject
        end
    end

    describe '#ticks' do
        context 'when the reactor is' do
            context 'not running' do
                it 'returns 0' do
                    subject.ticks.should == 0
                end
            end

            context 'running' do
                it 'returns the amount of loop iterations' do
                    run_reactor_in_thread
                    sleep 1
                    subject.ticks.should > 1
                end
            end

            context 'stopped' do
                it 'sets it to 0' do
                    run_reactor_in_thread
                    sleep 1
                    subject.stop
                    sleep 0.1 while subject.running?

                    subject.ticks.should == 0
                end
            end
        end
    end

    describe '#run' do
        it 'runs the reactor loop' do
            run_reactor_in_thread
            sleep 1
            subject.ticks.should > 0
        end

        context 'when a block is given' do
            it 'is called ASAP' do
                subject.run do
                    subject.should be_running
                    subject.ticks.should == 0
                    subject.stop
                end
            end
        end

        context 'when already running' do
            it 'schedules a task to be run at the next tick' do
                thread = run_reactor_in_thread

                reactor_thread = nil
                subject.run do
                    reactor_thread = Thread.current
                end

                sleep 0.1 while !reactor_thread

                reactor_thread.should be_kind_of Thread
                reactor_thread.should_not == Thread.current
                thread.should == reactor_thread
            end
        end
    end

    describe '#run_in_thread' do
        it 'runs the Reactor in a Thread' do
            thread = subject.run_in_thread
            subject.should be_running
            thread.should_not == Thread.current
            subject.thread.should == thread
        end

        context 'when already running' do
            it "raises #{klass::Error::AlreadyRunning}" do
                subject.run_in_thread
                expect { subject.run_in_thread }.to raise_error klass::Error::AlreadyRunning
            end
        end
    end

    describe '#run_block' do
        it 'runs the reactor loop just for the given block' do
            running = false
            subject.run_block do
                running = subject.running?
            end

            subject.should_not be_running
            running.should be_true
        end

        context 'when no block is given' do
            it "raises #{ArgumentError}" do
                expect { subject.run_block }.to raise_error ArgumentError
            end
        end

        context 'when already running' do
            it "raises #{klass::Error::AlreadyRunning}" do
                run_reactor_in_thread
                expect { subject.run_block{} }.to raise_error klass::Error::AlreadyRunning
            end
        end
    end

    describe '#on_tick' do
        it "schedules a task to be run at each tick in the #{klass}#thread" do
            counted_ticks  = 0
            reactor_thread = nil

            thread = run_reactor_in_thread

            subject.on_tick do
                reactor_thread = Thread.current
                counted_ticks += 1
            end

            sleep 1

            subject.ticks.should == counted_ticks

            reactor_thread.should be_kind_of Thread
            reactor_thread.should_not == Thread.current
            thread.should == reactor_thread
        end

        context 'when the reactor is not running' do
            it "raises #{klass::Error::NotRunning}" do
                expect do
                    subject.on_tick{}
                end.to raise_error klass::Error::NotRunning
            end
        end
    end

    describe '#schedule' do
        context 'when the reactor is running' do
            context 'in the same thread' do
                it 'calls the block right away' do
                    subject.run_block do
                        out_tick = subject.ticks
                        in_tick  = nil

                        subject.schedule do
                            in_tick = subject.ticks
                        end

                        out_tick.should == in_tick
                    end
                end
            end

            context 'in a different thread' do
                it 'calls the block at the next tick' do
                    t = run_reactor_in_thread

                    subject.schedule do
                        subject.should be_in_same_thread
                        subject.stop
                    end
                    t.join
                end
            end
        end

        context 'when the reactor is not running' do
            it "raises #{klass::Error::NotRunning}" do
                expect do
                    subject.schedule{}
                end.to raise_error klass::Error::NotRunning
            end
        end
    end

    describe '#next_tick' do
        it "schedules a task to be run at the next tick in the #{klass}#thread" do
            thread = run_reactor_in_thread

            reactor_thread = nil
            subject.next_tick do
                reactor_thread = Thread.current
            end

            sleep 0.1 while !reactor_thread

            reactor_thread.should be_kind_of Thread
            reactor_thread.should_not == Thread.current
            thread.should == reactor_thread
        end

        context 'when the reactor is not running' do
            it "raises #{klass::Error::NotRunning}" do
                expect do
                    subject.next_tick{}
                end.to raise_error klass::Error::NotRunning
            end
        end
    end

    describe '#at_interval' do
        it "schedules a task to be run at the given interval in the #{klass}#thread" do
            counted_ticks  = 0
            reactor_thread = nil

            thread = run_reactor_in_thread

            subject.at_interval 0.5 do
                reactor_thread = Thread.current
                counted_ticks += 1
            end

            sleep 2

            counted_ticks.should == 3

            reactor_thread.should be_kind_of Thread
            reactor_thread.should_not == Thread.current
            thread.should == reactor_thread
        end

        context 'when the reactor is not running' do
            it "raises #{klass::Error::NotRunning}" do
                expect do
                    subject.at_interval(1){}
                end.to raise_error klass::Error::NotRunning
            end
        end
    end

    describe '#delay' do
        it "schedules a task to be run at the given time in the #{klass}#thread" do
            counted_ticks  = 0
            reactor_thread = nil
            call_time      = nil

            thread = run_reactor_in_thread

            subject.delay 1 do
                reactor_thread = Thread.current
                call_time      = Time.now
                counted_ticks += 1
            end

            sleep 3

            (Time.now - call_time).to_i.should == 1
            counted_ticks.should == 1

            reactor_thread.should be_kind_of Thread
            reactor_thread.should_not == Thread.current
            thread.should == reactor_thread
        end

        context 'when the reactor is not running' do
            it "raises #{klass::Error::NotRunning}" do
                expect do
                    subject.delay(1){}
                end.to raise_error klass::Error::NotRunning
            end
        end
    end

    describe '#thread' do
        context 'when the reactor is' do
            context 'not running' do
                it 'returns nil' do
                    subject.thread.should be_nil
                end
            end

            context 'running' do
                it 'returns the thread of the reactor loop' do
                    thread = reactor.run_in_thread

                    subject.thread.should == thread
                    subject.thread.should_not == Thread.current
                end
            end

            context 'stopped' do
                it 'sets it to nil' do
                    reactor.run_in_thread
                    sleep 1
                    subject.stop
                    sleep 0.1 while subject.running?

                    subject.thread.should be_nil
                end
            end
        end
    end

    describe '#in_same_thread?' do
        context 'when running in the same thread as the reactor loop' do
            it 'returns true' do
                t = run_reactor_in_thread
                sleep 0.1

                subject.next_tick do
                    subject.should be_in_same_thread
                    subject.stop
                end

                t.join
            end
        end
        context 'when not running in the same thread as the reactor loop' do
            it 'returns false' do
                run_reactor_in_thread
                sleep 0.1

                subject.should_not be_in_same_thread
            end
        end
        context 'when the reactor is not running' do
            it "raises #{klass::Error::NotRunning}" do
                expect { subject.in_same_thread? }.to raise_error klass::Error::NotRunning
            end
        end
    end

    describe '#running?' do
        context 'when the reactor is running' do
            it 'returns true' do
                run_reactor_in_thread

                subject.should be_running
            end
        end

        context 'when the reactor is not running' do
            it 'returns false' do
                subject.should_not be_running
            end
        end

        context 'when the reactor has been stopped' do
            it 'returns false' do
                run_reactor_in_thread

                Timeout.timeout 10 do
                    sleep 0.1 while !subject.running?
                end

                subject.should be_running
                subject.stop

                Timeout.timeout 10 do
                    sleep 0.1 while subject.running?
                end

                subject.should_not be_running
            end
        end
    end

    describe '#stop' do
        it 'stops the reactor' do
            subject.run_in_thread

            subject.should be_running
            subject.stop

            Timeout.timeout 10 do
                sleep 0.1 while subject.running?
            end

            subject.should_not be_running
        end
    end

    describe '#connect' do
        context 'when using UNIX domain sockets' do
            it "returns #{klass::Connection}" do
                subject.run_block do
                    subject.connect( @unix_socket, echo_client_handler ).should be_kind_of klass::Connection
                end
            end

            it 'establishes a connection' do
                outside_thread = Thread.current
                subject.run do
                    Thread.current[:outside_thread] = outside_thread
                    Thread.current[:data] = data

                    subject.connect( @unix_socket, echo_client_handler ) do |c|
                        def c.on_connect
                            super
                            send_data Thread.current[:data]
                        end

                        def c.on_close( _ )
                            Thread.current[:outside_thread][:received_data] = received_data
                        end
                    end
                end

                outside_thread[:received_data].should == data
            end

            context 'when the socket is invalid' do
                it "calls #on_close with #{klass::Connection::Error::HostNotFound}" do
                    outside_thread = Thread.current
                    subject.run do
                        Thread.current[:outside_thread] = outside_thread

                        subject.connect( 'blahblah', echo_client_handler ) do |c|
                            def c.on_close( reason )
                                Thread.current[:outside_thread][:error] = reason
                                reactor.stop
                            end
                        end
                    end

                    Thread.current[:outside_thread][:error].should be_a_kind_of klass::Connection::Error::HostNotFound
                end
            end
        end

        context 'when using TCP sockets' do
            it "returns #{klass::Connection}" do
                subject.run_block do
                    subject.connect( @host, @port, echo_client_handler ).should be_kind_of klass::Connection
                end
            end

            it 'establishes a connection' do
                outside_thread = Thread.current
                subject.run do
                    Thread.current[:outside_thread] = outside_thread
                    Thread.current[:data] = data

                    subject.connect( @host, @port, echo_client_handler ) do |c|
                        def c.on_connect
                            super
                            send_data Thread.current[:data]
                        end

                        def c.on_close( _ )
                            Thread.current[:outside_thread][:received_data] = received_data
                        end
                    end
                end

                outside_thread[:received_data].should == data
            end

            context 'when the host is invalid' do
                it "calls #on_close with #{klass::Connection::Error::HostNotFound}" do
                    outside_thread = Thread.current
                    subject.run do
                        Thread.current[:outside_thread] = outside_thread

                        subject.connect( 'blahblah', 9876, echo_client_handler ) do |c|
                            def c.on_close( reason )
                                Thread.current[:outside_thread][:error] = reason
                                reactor.stop
                            end
                        end
                    end

                    Thread.current[:outside_thread][:error].should be_a_kind_of klass::Connection::Error::HostNotFound
                end
            end

            context 'when the port is invalid' do
                it "calls #on_close with #{klass::Connection::Error::Refused}" do
                    outside_thread = Thread.current
                    subject.run do
                        Thread.current[:outside_thread] = outside_thread

                        subject.connect( @host, @port + 1, echo_client_handler ) do |c|
                            def c.on_close( reason )
                                Thread.current[:outside_thread][:error] = reason
                                reactor.stop
                            end
                        end
                    end

                    Thread.current[:outside_thread][:error].should be_a_kind_of klass::Connection::Error::Refused
                end
            end
        end

        context 'when handler options have been provided' do
            it 'initializes the handler with them' do
                options = [:blah, { some: 'stuff' }]

                subject.run_block do
                    subject.connect( @host, @port, echo_client_handler, *options ).
                        initialization_args.should == options
                end
            end
        end

        context 'when the reactor is not running' do
            it "raises #{klass::Error::NotRunning}" do
                expect do
                    subject.connect( 'blahblah', echo_client_handler )
                end.to raise_error klass::Error::NotRunning
            end
        end
    end

    describe '#listen' do
        let(:host) { 'localhost' }
        let(:port) { Servers.available_port }
        let(:unix_socket) { port_to_socket Servers.available_port }

        context 'when using UNIX domain sockets' do
            it "returns #{klass::Connection}" do
                subject.run_block do
                    subject.listen( unix_socket, echo_server_handler ).should be_kind_of klass::Connection
                end
            end

            it 'listens for incoming connections' do
                subject.run_in_thread

                subject.listen( unix_socket, echo_server_handler )

                @socket = unix_writer.call( unix_socket, data )
                @socket.read( data.size ).should == data
            end

            context 'when the socket is invalid' do
                it "raises #{klass::Connection::Error::Permission}" do
                    subject.run_in_thread
                    expect do
                        subject.listen( '/socket', echo_server_handler )
                    end.to raise_error klass::Connection::Error::Permission
                end
            end
        end

        context 'when using TCP sockets' do
            it "returns #{klass::Connection}" do
                subject.run_block do
                    subject.listen( host, port, echo_server_handler ).should be_kind_of klass::Connection
                end
            end

            it 'listens for incoming connections' do
                subject.run_in_thread

                subject.listen( host, port, echo_server_handler )

                @socket = tcp_writer.call( host, port, data )
                @socket.read( data.size ).should == data
            end

            context 'when the host is invalid' do
                it "raises #{klass::Connection::Error::HostNotFound}" do
                    subject.run_in_thread

                    expect do
                        subject.listen( 'host', port, echo_server_handler )
                    end.to raise_error klass::Connection::Error::HostNotFound
                end
            end

            context 'when the port is invalid' do
                it "raises #{klass::Connection::Error::Permission}" do
                    subject.run_in_thread

                    expect do
                        subject.listen( host, 1, echo_server_handler )
                    end.to raise_error klass::Connection::Error::Permission
                end
            end
        end

        context 'when handler options have been provided' do
            it 'initializes the handler with them' do
                options = [:blah, { some: 'stuff' }]

                subject.run_in_thread

                subject.listen( host, port, echo_server_handler, *options )

                @socket = tcp_writer.call( host, port, data )
                subject.connections.values.first.initialization_args.should == options
            end
        end

        context 'when the reactor is not running' do
            it "raises #{klass::Error::NotRunning}" do
                expect do
                    subject.listen( host, port, echo_server_handler )
                end.to raise_error klass::Error::NotRunning
            end
        end
    end
end
