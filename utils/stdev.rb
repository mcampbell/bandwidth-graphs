#!/usr/bin/env ruby

# Helper script to generate a standard deviation of input values.  It
# is assumed that the input args are:
# 1 - the path to the database
# 2 - a piece of sql to run that will spit out exactly 2 columns; "key
# value" (both integers). For each key, the output will be: <key>
# <mean> <stdev>

require 'descriptive_statistics'

db = Hash.new
# all_metrics = Array.new

`sqlite3 -column "#{ARGV[0]}" "#{ARGV[1]}"`.split(/\n/).each do |line|
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
