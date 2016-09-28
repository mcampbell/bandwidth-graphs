#!/usr/bin/env ruby


# Helper script to generate an exponentially smoothed moving average.

require 'getopt/std'

opt = Getopt::Std.getopts("s:")

samples = (opt['s'] || 3).to_i
raise "Number of samples must be > 1.  It is #{samples}" if samples <= 1

eps = 2.0 / (samples.to_f + 1.0)

ma = nil

while (line = gets) do
  line = line.strip.chomp

  (key, metric) = line.split(/\s+/)
  metric = metric.to_i

  ma = ma.nil? ? metric.to_f : (eps * metric) + ((1.0 - eps) * ma)

  puts "#{key}  #{ma}"
end

  
