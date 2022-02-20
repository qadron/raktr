require 'spec_helper'

describe Raktr::Queue do
    let(:raktr) { Raktr.new }
    subject { described_class.new raktr }

    describe '#initialize' do
        it 'sets the associated raktr' do
            subject.raktr.should == raktr
        end
    end

    describe '#pop' do
        context 'when the queue is not empty' do
            it 'passes the next item to the block' do
                passed_item = nil

                raktr.run do
                    subject << :my_item
                    subject.pop do |item|
                        passed_item = item
                        raktr.stop
                    end
                end

                passed_item.should == :my_item
            end
        end

        context 'when the queue is empty' do
            it 'assigns a block to handle new items' do
                passed_item = nil

                raktr.run do
                    subject.pop do |item|
                        passed_item = item
                        raktr.stop
                    end

                    subject << :my_item
                end

                passed_item.should == :my_item
            end
        end
    end

    describe '#empty?' do
        context 'when the queue is empty' do
            it 'returns true' do
                subject.should be_empty
            end
        end

        context 'when the queue is not empty' do
            it 'returns false' do
                raktr.run_block do
                    subject << nil
                    subject.should_not be_empty
                end
            end
        end
    end

    describe '#size' do
        it 'returns the queue size' do
            raktr.run_block do
                2.times { |i| subject << i }
                subject.size.should == 2
            end
        end
    end

    describe '#num_waiting' do
        context 'when no jobs are available to handle new items' do
            it 'returns 0' do
                subject.num_waiting.should == 0
            end
        end

        context 'when there are jobs waiting to handle new items' do
            it 'returns a count' do
                raktr.run_block do
                    3.times { subject.pop{} }
                    subject.num_waiting.should == 3
                end
            end
        end
    end

end
