#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'optparse'
require 'fileutils'
require 'active_support/core_ext/hash/conversions'

# A simple class to override default ruby YAML parsing of the over and
# ball entry from the YAML. The 0.9 data has it as a simple float,
# meaning that 0.10 (the 10th ball of the 1st over) incorrectly becomes
# 0.1. This fixes the problem by simply returning the original string.
class CricsheetScalarScanner < Psych::ScalarScanner
  def tokenize(string)
    return string if string =~ /^\d+\.\d+$/
    super
  end
end

# A simple class to load YAML while using a custom scanner.
class YamlLoader
  def initialize(file)
    @file = file
    @@class_loader ||= Psych::ClassLoader.new
    @@tree_converter ||= Psych::Visitors::ToRuby.new(
      CricsheetScalarScanner.new(@@class_loader),
      @@class_loader
    )
  end

  def run
    @@tree_converter.accept(YAML.parse_file(@file))
  end
end

options = { output_folder: 'tmp' }
OptionParser.new do |opts|
  opts.banner = 'Usage: convert.rb [options]'

  opts.on('-f FOLDER', '--output-folder FOLDER',
          'Folder to write the results to') do |folder|
    options[:output_folder] = folder
  end

  opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
    options[:verbose] = v
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end.parse!

# Which files are we converting?
files = ARGV || []
if files.empty?
  puts 'You must provide some files to be converted'
  exit 1
end

# Make sure our output directory is there.
FileUtils.mkdir_p(options[:output_folder])

files.each_with_index do |file, index|
  puts format('%d of %d - %s',
              index + 1, files.size, file) if options[:verbose]

  yaml = YamlLoader.new(file).run

  data = yaml.slice('meta', 'info')
  if data['info'].key?('supersubs')
    data['info']['supersubs'] = data['info']['supersubs'].map do |team, player|
      { 'team' => team, 'player' => player }
    end
  end

  data[:innings] = yaml['innings'].collect.with_index do |inning, inning_index|
    inning_name = inning.keys.first
    inning_data = inning[inning_name]

    # Tidy the deliveries.
    delivery_data = inning_data['deliveries'].collect do |delivery|
      over, ball = delivery.keys.first.to_s.split('.')

      delivery_data = delivery.values.first
      wickets_data = if delivery_data.key?('wicket')
                       { wickets: [delivery_data['wicket']].flatten }
                     else
                       {}
                     end

      { over: over, ball: ball }
        .merge(delivery_data.except('wicket'))
        .merge(wickets_data)
    end

    { inningsNumber: inning_index + 1 }
      .merge(inning_data.slice('team', 'penalty_runs'))
      .merge(deliveries: delivery_data)
  end

  # Generate the xml, and write it out.
  xml_filename = "#{File.basename(file, '.*')}.xml"
  output_path = File.join(options[:output_folder], xml_filename)
  xml = data.to_xml(root: 'cricsheet', skip_types: true, dasherize: false)
  File.write(output_path, xml)
end
