require "kametori/version"

module Kametori
  # exception classes
  class Timeout < StandardError
  end

  class << self
    attr_accessor :raise_errors
    def reset!
      @raise_errors = false
      @limits = []
      @repeat_count = 1
    end
    def scenario_limits=(limits)
      check_limits (limits)
      @limits = limits
    end

    def scenario_limits
      @limits || []
    end

    def average_over=(count)
      raise( ArgumentError, "Wrong average over count") unless count.is_a? Integer
      raise( ArgumentError, "Wrong average over count") if count < 1
      @repeat_count = count
    end

    def current_scenario
      @current_scenario || {}
    end

    def average_over
      current_scenario[:average_over] || @repeat_count || 1
    end

    def scenario_benchmark(scenario, options={}, &block)
      under_test = find_scenario_under_test(scenario)
      return nil if under_test.nil?
      return nil unless block_given?
      
      elapsed = execute_with_timing(average_over) { block.call }
      limit = under_test[:limit]
      check_finish_on_time(elapsed,limit)
      elapsed
    end
    
    private

    def check_limits(limits)
      correct = limits.is_a?(Array) &&
                limits.all? { |l| l.include?(:tag) && l.include?(:limit) && l[:limit].is_a?(Numeric)}
      raise( ArgumentError, "wrong scenario limits") unless correct
    end

    def find_scenario_under_test(scenario)
      @current_scenario = @limits.find{ |limit| scenario.source_tag_names.include? limit[:tag] }
    end

    def execute_with_timing(average_over)
      elapsed = []
      average_over.times do
        before = Time.now
        yield
        after = Time.now
        elapsed.push (after - before)
      end
      mean(elapsed)
    end

    def check_finish_on_time( elapsed, limit )
      if raise_errors
        if ( elapsed > limit)
          raise Timeout, "Scenario timed out with #{format_float(elapsed)} > #{limit}"
        end
      end
    end

    def format_float(float)
      "%.3f" % float
    end

    def mean(array)
      sum = array.inject(0){ |accum, i| accum + i }
      sum / array.length.to_f
    end

  end
end
