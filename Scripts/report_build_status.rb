require_relative 'script_helper_factory'
require 'optparse'

options = {}
OptionParser.new do |opts|
    opts.on('-i', '--id ID', Integer, 'The id of the build') do |v|
        options[:id] = v
    end
    opts.on('-s', '--status STATUS', String, 'The build status') do |v|
        options[:status] = v
    end
    opts.on('-o', '--output_file [STRING]', String, 'The build output file path') do |v|
        options[:output_file] = v
    end
    opts.on('-e', '--email [STRING]', String, 'The email in case of failure') do |v|
        options[:failure_email] = v
    end
end.parse!

if options[:id].nil?
    raise('build id must be passed with -i / --id')
end

if options[:status].nil?
    raise('status must be passed with -s / --status')
end

script_helper = create_script_helper
script_helper.report_build(options[:id], options[:status], options[:output_file], options[:failure_email])
