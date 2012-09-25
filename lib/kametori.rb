require "kametori/version"

module Kametori
  # exception classes
  class Error < RuntimeError
  end
  class Timeout < RuntimeError

  end

  class << self
    def limits=(limits)
      raise Error if !limits.is_a? Array
      @limits = limits
    end

    def limits
      @limits
    end

    def benchmark_scenario(scenario, options={})
      under_test = @limits.find{ |limit| limit[:tag] == scenario.tag}
      return nil if under_test.nil?
      before = Time.now
        yield if block_given?
      after = Time.now
      elapsed = after - before
      if options[:raise]
        if ( elapsed > under_test[:limit])
          raise Timeout
        end
      end
      elapsed
    end
    
  end
end
