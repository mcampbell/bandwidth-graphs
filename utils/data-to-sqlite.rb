#!/usr/bin/env ruby

# -- 2016.05.26-00.24.44,4,0,96,up,10.13,e6510
# create table bandwidth (
#        test_time    TEXT,
#        day_of_week  INTEGER,
#        hour_of_day  INTEGER,
#        hour_of_week INTEGER,
#        metric_type  TEXT,
#        metric_value REAL,
#        context      TEXT);


# This script reads from the raw dataset and generates sqlite code to
# insert into the database.  This is used if you end up with corrupt
# data in the db and want to recreate it.
# Note that it just generates the SQL; it's up you to to capture it
# and run it.
# eg:
# ruby ./utils/data-to-sqlite.rb < ./data/speedtest.data | sqlite3 st
# (where "st" is the speedtest table)


puts "delete from bandwidth;"

while (line = gets) do
  line.chomp!
  line = line.gsub(/#.*/, '').strip
  next if line.nil? or line == ""
  (d, dow, hod, how, type, val, ctx) = line.split(/,/)

  puts "insert into bandwidth values('#{d}', #{dow}, #{hod}, #{how}, '#{type}', #{val}, '#{ctx}');"
end

  
