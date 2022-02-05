#!/usr/bin/env ruby

require 'json'

template_path = ARGV[0]
palette_path = ARGV[1]

unless template_path && palette_path
  $stderr.puts "Usage: #{$PROGRAM_NAME} <template path> <palette path>"
  exit 1
end

template = JSON.parse(File.read(template_path))
palette = JSON.parse(File.read(palette_path))

def traverse_hash(hash, path = [], &block)
  return enum_for(:traverse_hash, hash, path) unless block_given?

  hash.each do |key, value|
    key_path = path + [key]
    if value.is_a? Hash
      traverse_hash(value, key_path, &block)
    else
      yield key_path, value
    end
  end
end

def flatten_hash(deep_hash)
  traverse_hash(deep_hash).each_with_object({}) do |(path, value), shallow_hash|
    shallow_hash[path.join('.')] = value
  end
end

#:nodoc:
class Hash
  def bury(*args)
    raise ArgumentError, '2 or more arguments required' if args.count < 2

    if args.count == 2
      self[args[0]] = args[1]
    else
      arg = args.shift
      self[arg] ||= {}
      self[arg].bury(*args)
    end
    self
  end
end

colors = flatten_hash(palette)
theme = template.dup

traverse_hash(template) do |path, value|
  resolved_value = colors[value]
  theme.bury(*path, resolved_value) if resolved_value
end

puts JSON.pretty_generate(theme)
