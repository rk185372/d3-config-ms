#!/usr/bin/env ruby

require 'json'

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

template_path = ARGV[0]
theme_path = ARGV[1]

unless template_path && theme_path
    warn "Usage: #{$PROGRAM_NAME} <template path> <theme path>"
    exit 1
end

template = JSON.parse(File.read(template_path))
theme = JSON.parse(File.read(theme_path))

flat_template = flatten_hash(template)
flat_theme = flatten_hash(theme)

missing_keys = flat_template.keys - flat_theme.keys
extra_keys = flat_theme.keys - flat_template.keys

if missing_keys.length > 0
    warn "#{missing_keys} are missing from the themes file."
    exit 1
end

if extra_keys.length > 0
    warn "#{extra_keys} are extra keys from the themes file."
    exit 1
end

puts 'Json files have the same keys.'
exit 0
