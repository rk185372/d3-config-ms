require_relative 'script_helper_factory'
require_relative 'project_builder/project_builder'

raise('build_id must be passed in as the first argument.') if ARGV[0].nil?

build_id = ARGV[0].to_i

script_helper = create_script_helper

puts "⚒ Downloading Environment..."
script_helper.download_environment_zip_for_build(build_id)

puts "⚒ Building Podfile and Project File..."
project_builder = ProjectBuilder.new()
project_builder.build(ARGV[1] == 'onCIServer')

generated_dir = "D3\ Banking/Generated"
Dir.mkdir(generated_dir) unless File.exists?(generated_dir)

FileUtils.touch("#{generated_dir}/Navigation.swift")
FileUtils.touch("#{generated_dir}/componentkit-registration.generated.swift")

puts "⚒ Running xcodegen..."
exec("xcodegen")
