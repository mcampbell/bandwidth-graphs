#!/usr/bin/env ruby

# helper script for trend generation.  Basically a time parser for gnuplot output.

require 'time'

want_dir = ARGV[0]
hardcoded_val = ARGV[1]
raise "usage: ruby trend.rb <directon> [value]" unless want_dir


# 2016-05-27 19:59:01-04:00,5,19,139,up,11.82,e6510
while (line = $stdin.gets) do
  line.chomp!
  line = line.gsub(/#.*/, '')
  next if (line == '' or line.nil?)
  
  (d, dow, hod, how, dir, val, ctx) = line.split(/,/)

  dt = Time.parse(d)

  if hardcoded_val.nil?
    puts "#{dt.strftime('%Y-%m-%d.%H-%M-%S')}     #{val}" if dir == want_dir
  else
    puts "#{dt.strftime('%Y-%m-%d.%H-%M-%S')}     #{hardcoded_val}" if dir == want_dir
  end
end
