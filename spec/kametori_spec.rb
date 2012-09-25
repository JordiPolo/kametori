require 'spec_helper'

# our mock for a cucumber scenario
class Scenario
  attr_accessor :source_tag_names
  attr_accessor :execution_time
  attr_reader :times_called
  def initialize (names)
    @source_tag_names = [*names]
    @execution_time = 0.1
    @times_called = 0
  end
  def execute
    Timecop.travel Time.now + @execution_time
    @times_called += 1
  end
end

describe Kametori do 

=begin
  describe '.standard=' do 
    it 'raises Kametori::Error if is an unknown standard' do
      expect {Kametori.standard='asdfasdf'}.to raise_error(Kamitori::Error)
    end
  end

  describe '.speed_test' do
  end
=end
  describe '.scenario_limits=' do 
    it 'should raise an error if the param is not an array' do
      expect { Kametori.scenario_limits= 2 }.to raise_error(ArgumentError, "wrong scenario limits")
    end
    it 'should raise an error if there is no limit for tag' do
      expect { Kametori.scenario_limits=[{tag:"aa"}] }.to raise_error(ArgumentError, "wrong scenario limits")
    end
    it 'should raise and error if there is no tag for limit' do 
      expect { Kametori.scenario_limits=[{limit:2}] }.to raise_error(ArgumentError, "wrong scenario limits")
    end
    it 'should raise and error if limit is not numeric' do 
      limits = [{ tag: "A", limit: "a"} ]
      expect { Kametori.scenario_limits= limits }.to raise_error(ArgumentError, "wrong scenario limits")
    end
    it 'should set the limits for the tags' do 
      limits = [{ tag: "A", limit: 1} ]
      Kametori.scenario_limits = limits
      Kametori.scenario_limits.should == limits 
    end
  end
  
  describe '.reset!' do
    it 'should reset to the defaults' do
      Kametori.reset!
      Kametori.average_over.should == 1
      Kametori.scenario_limits.should be_empty
      Kametori.raise_errors.should be_false
    end
  end
  describe '.average_over' do
    it 'should raise an error if the parameter is not integer' do
      expect { Kametori.average_over=1.2 }.to raise_error(ArgumentError, "Wrong average over count")
    end
    it 'should raise an error if the parameter is less than 1' do 
      expect { Kametori.average_over=0 }.to raise_error(ArgumentError, "Wrong average over count")
    end
    it 'defaults to 1 executions' do
      Kametori.average_over.should == 1
      Kametori.average_over= 10
      Kametori.average_over.should == 10
    end
  end

  describe '.scenario_benchmark' do
    before do
      @time_limit = 0.2
      Timecop.freeze Time.now
      limits = [{ tag: "MyTag", limit: @time_limit}, {tag: "MyTag2", limit:@time_limit} ]
      Kametori.scenario_limits = limits
      Kametori.average_over= 1
    end
    it 'should return nil if we do not have a limit for this scenario' do
      scenario = Scenario.new("OtherTag")
      Kametori.scenario_benchmark( scenario ) do
        scenario.execute
      end.should == nil
    end
    it 'should return nil if no block given' do
      scenario = Scenario.new("MyTag")
      Kametori.scenario_benchmark( scenario ).should == nil
    end
    it 'should return the time it took to finish the scenario' do
      scenario = Scenario.new("MyTag")
      Kametori.scenario_benchmark( scenario ) do
        scenario.execute
      end.should >= 0.1
    end

    it 'should work with scenarios with several tags' do
      scenario = Scenario.new(["MyTag", "otherTag", "one_more"])
      Kametori.scenario_benchmark( scenario ) do
        scenario.execute
      end.should >= 0.1
    end

    describe '.average_over' do 
      it 'should call average_over times the block passed' do
        scenario = Scenario.new("MyTag")
        Kametori.average_over = 5
        Kametori.scenario_benchmark( scenario ) do
          scenario.execute
        end
        scenario.times_called.should == 5
        Kametori.average_over = 1
      end
      it '.average_over can be overriden by the value in the hash' do
        old_limits = Kametori.scenario_limits
        limits = [{ tag: "MyTag", limit: @time_limit, average_over: 2}, {tag: "MyTag2", limit:@time_limit} ]
        Kametori.scenario_limits = limits
        Kametori.average_over = 5
        scenario = Scenario.new("MyTag")
        Kametori.scenario_benchmark( scenario ) do
          scenario.execute
        end
        scenario.times_called.should == 2
        Kametori.scenario_limits = old_limits
      end
    end

    describe '.raise_errors' do
      it 'should return the time it took to finish the scenario and not raise if it finished before the limit' do
        scenario = Scenario.new("MyTag")
        Kametori.raise_errors = true
        Kametori.scenario_benchmark( scenario ) do
          scenario.execute
        end.should < 0.2
      end

      it 'should raise Kametori::Timeout if the scenario is slower than its limit and we set to raise' do
        scenario = Scenario.new("MyTag")
        scenario.execution_time = 0.21
        Kametori.raise_errors = true
        expect do
          Kametori.scenario_benchmark( scenario ) do
            scenario.execute
          end
        end.to raise_error( Kametori::Timeout, /Scenario timed out with [0-9]*\.?[0-9]{3} > #{@time_limit}/ )
      end
    end

  end
end
