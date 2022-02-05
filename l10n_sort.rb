require 'JSON'

output = File.open('LocalizableStringsDefinition.json', 'r') do |file|
  JSON.parse(file.read).sort.to_h
end

File.open('LocalizableStringsDefinition.json', 'w+') do |file|
  file.write(JSON.pretty_generate(output, indent: '    '))
  file.write("\n")
end
