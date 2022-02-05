#!/usr/bin/ruby
require 'json'
require 'fileutils'
require 'net/http'

$SRC_DIR = __dir__
$DEST_DIR = "#{Dir.home}"

def check_plugin_directory()
  flipper_dest_plugin_directory = "#{$DEST_DIR}/.flipper/flipper-plugins"
  puts "Checking if themeLoaderPlugin directory exists..."

  if Dir.exist?(flipper_dest_plugin_directory)
    puts "themeLoaderPlugin directory exists"
    check_config()
  else
    puts "Creating themeLoaderPlugin folder"
    src_plugin_path = "#{$SRC_DIR}/flipper-plugins/"
    dest_plugin_path = "#{$DEST_DIR}/.flipper/."
    FileUtils.cp_r(src_plugin_path, dest_plugin_path)
  end
end


def check_config()
  config_path= "#{$DEST_DIR}/.flipper/config.json"
  puts "Checking if config.json exists..."

  if File.exist?(config_path)
    puts "Config.json file exists"
    check_configuration()
  else
    src_plugin_path = "#{$SRC_DIR}/config.json"
    dest_plugin_path = "#{$DEST_DIR}/.flipper/."
    FileUtils.cp_r(src_plugin_path, dest_plugin_path)
    puts "config.json file created"
  end
end


def check_configuration()
  config_file = "#{$DEST_DIR}/.flipper/config.json"
  puts "Checking config.json configuration..."

  json = File.read(config_file)
  hash = JSON.parse(json)
  plugin_hash = hash["pluginPaths"]

  if plugin_hash.include?("flipper-plugins")
    puts "config.json configured correctly"
  else
    puts "Configuring Plugin"
    hash["pluginPaths"] <<  "flipper-plugins"
    File.open("#{config_file}","w") do |f|
      f.write(hash.to_json)
    end
    puts "Configuration Successful"
  end

end


def check_is_watchman_installed()
  check_is_brew_installed()
  puts "Checking if Watchman is installed..."
  is_watchman_installed = system("which watchman")
  if is_watchman_installed == false
    puts "Watchman is not installed"
    puts "Installing Watchman"
    system("brew install watchman")
  else
    puts "Watchman exists"
  end
end


def check_is_brew_installed()
  puts "Checking if Brew is installed..."
  is_brew_installed = system("which brew")
  if is_brew_installed == false
    puts "Brew is not installed"
    puts "Installing brew"
    homebrew_uri = URI('https://raw.githubusercontent.com/Homebrew/install/master/install')
    homebrew_script = Net::HTTP.get(homebrew_uri)
    eval(homebrew_script)
  else
    puts "Brew exists"
  end
end

check_plugin_directory()
check_is_watchman_installed()
puts "Starting Flipper"
system("/Applications/Flipper.app/Contents/MacOS/Flipper")
