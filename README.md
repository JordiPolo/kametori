# Kametori

Kametori helps you to write a benchmark test suite

## Installation

Add this line to your application's Gemfile:

    gem 'kametori'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kametori

## Usage

The best way to use this gem is adding a profile to your
cucumber.yml file (usually located in config in Rails projects).
Like:

    benchmark: --format progress -r features/support/benchmark.rb

And in features/support/benchmark.rb you write:

     Kametori.scenario_limits = [{ tag: "fast_scenario", limit:1 },
     {tag:"slow_scenario", limit:10}]
   
     Kametori.raise_errors = true

 Around do |scenario, block|
   Kametori.scenario_benchmark(scenario) do
     block.call
   end
 end




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
