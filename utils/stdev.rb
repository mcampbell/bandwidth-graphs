#!/usr/bin/env ruby

# Helper script to generate a standard deviation of input values.  It
# is assumed that the input arg is a piece of sql to run that will
# spit out exactly 2 columns; "key value" (both integers).  For each
# key, the output will be:
# <key> <mean> <stdev>

require 'descriptive_statistics'

db = Hash.new
# all_metrics = Array.new

`sqlite3 -column st "#{ARGV[0]}"`.split(/\n/).each do |line|
  line.strip.chomp!
  (key, metric) = line.split(/\s+/)

  key = key.to_i
  metric = metric.to_i

#  all_metrics << metric

  metrics = db[key]
  metrics ||= Array.new
  db[key] = metrics

  metrics << metric
end

db.keys.sort.each do |key|
  metrics = db[key]
  stdev = DescriptiveStatistics.standard_deviation(metrics)
  mean = DescriptiveStatistics.mean(metrics)
  puts "#{key} #{mean} #{stdev}" 
end
