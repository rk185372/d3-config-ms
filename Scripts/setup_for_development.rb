require_relative 'script_helper_factory'
require_relative 'project_builder/project_builder'

script_helper = create_script_helper

puts "⚒ Downloading Environment..."
script_helper.download_cached_environment_zip_for_active_template(2)

puts "⚒ Building Podfile and Project File..."
project_builder = ProjectBuilder.new()
project_builder.build(ARGV[0] == 'onCIServer')

generated_dir = "D3\ Banking/Generated"
Dir.mkdir(generated_dir) unless File.exists?(generated_dir)

FileUtils.touch("#{generated_dir}/Navigation.swift")
FileUtils.touch("#{generated_dir}/componentkit-registration.generated.swift")

puts "⚒ Running xcodegen..."
exec("xcodegen")

