#!/usr/bin/ruby
require 'FHWiQisScraper.rb'

qis = FHWiQisScraper.new("user","pwd")
puts qis.getAverageGrade