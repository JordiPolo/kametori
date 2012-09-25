require 'spec_helper'

class Scenario #our scenario mock
  attr_accessor :tag
  attr_accessor :sleep_time
  def initialize 
    @sleep_time = 0.1
  end
  def execute
    sleep @sleep_time
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
  describe '.limits=' do 
    it 'should raise Kametori::Error if the param is not an array' do
      expect { Kametori.limits= 2 }.to raise_error(Kametori::Error)
    end
    it 'should set the limits for the tags' do 
      limits = [{ tag: "A", limit: 1} ]
      Kametori.limits = limits
      Kametori.limits.should == limits 
    end
  end

  describe '.benchmark_scenario' do 
    before do
      limits = [{ tag: "MyTag", limit: 0.5} ]
      Kametori.limits = limits
    end
    it 'should return nil if we do not have a limit for this scenario' do
      scenario = Scenario.new
      scenario.tag= "OtherTag"
      Kametori.benchmark_scenario( scenario ) do
        scenario.execute
      end.should == nil
    end
    it 'should return the time it took to finish the scenario' do 
      scenario = Scenario.new
      scenario.tag= "MyTag"
      Kametori.benchmark_scenario( scenario ) do
        scenario.execute
      end.should >= 0.1
    end

    it 'should return the time it took to finish the scenario and not raise if it finished before the limit' do 
      scenario = Scenario.new
      scenario.tag= "MyTag"
      Kametori.benchmark_scenario( scenario, raise: true ) do
        scenario.execute
      end.should >= 0.1
    end

    it 'should raise Kametori::Timeout if the scenario is slower than its limit and we set to raise' do
      scenario = Scenario.new
      scenario.tag= "MyTag"
      scenario.sleep_time = 0.6
      expect do
        Kametori.benchmark_scenario( scenario, raise: true ) do
          scenario.execute
        end
      end.to raise_error( Kametori::Timeout)
    end

  end
end
