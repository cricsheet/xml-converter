#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'

xsd = Nokogiri::XML::Schema(File.read('schema.xsd'))

# Which files are we validating?
files = ARGV || []
if files.empty?
  puts 'You must provide some files to be validated'
  exit 1
end

files.each do |file|
  doc = Nokogiri::XML(File.read(file))
  next if xsd.valid?(doc)

  puts "Errors found in #{file}"
  xsd.validate(doc).each do |error|
    puts format('  %s (Line %s, column %s)',
                error.message, error.line, error.column)
  end
end
