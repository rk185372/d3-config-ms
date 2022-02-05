require_relative 'script_helper_factory'
require_relative 'git_helper'

raise('template_id must be passed in as the first argument.') if ARGV[0].nil?

template_id = ARGV[0].to_i

script_helper = create_script_helper

build_id = script_helper.create_build(template_id, GitHelper.current_branch, GitHelper.current_commit)
script_helper.download_environment_zip_for_build(build_id)

file_name = 'd3_build_id'
File.delete(file_name) if File.exist?(file_name)
File.open(file_name, 'w') { |file| file.write(build_id) }
