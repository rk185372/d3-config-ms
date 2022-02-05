# This script will allow us to resize the watch and 
# iphone app icon files. This file 
# should have the dimensions 1024x1024 so that all of
# the other images are a scaled down version of this one.
# To run this script you will need the dependencies
#
# gem install fastimage
# gem install fastimage_resize
# gem install RubyInline
# brew install gd
#
# After running this script watch images will go to 
# "D3 Banking Watchkit App/Assets.xcassets/AppIcon.appiconset/"
# iphone images will go to "D3 Banking/Assets.xcassets/AppIcon.appiconset/"
require 'fastimage_resize'
require 'fileutils'


if ARGV[0] == nil
  puts "You need to pass in 1024x1024 png"
  exit 1
end

icon = "#{Dir.pwd}/#{ARGV[0]}"
if FastImage.size(icon) == [1024, 1024]
  watch_icons_path = 'D3 Banking Watchkit App/Assets.xcassets/AppIcon.appiconset/'
  phone_icons_path = 'D3 Banking/Assets.xcassets/AppIcon.appiconset/'

  FileUtils.mkdir_p watch_icons_path
  FileUtils.mkdir_p phone_icons_path

  # Create Watch Icons
  Dir.chdir(watch_icons_path) do
    FastImage.resize(icon, 88, 88, outfile: 'Apple-watch-home-screen-Icon-40mm-2X.png')
    FastImage.resize(icon, 80, 80, outfile: 'Apple-watch-home-screen-Icon-42mm-2X.png')
    FastImage.resize(icon, 100, 100, outfile: 'Apple-watch-home-screen-Icon-44mm-2X.png')
    FastImage.resize(icon, 172, 172, outfile: 'Apple-watch-short-look-Icon-38mm-2X.png')
    FastImage.resize(icon, 196, 196, outfile: 'Apple-watch-short-look-Icon-42mm-2X.png')
    FastImage.resize(icon, 216, 216, outfile: 'Apple-watch-short-look-Icon-44mm-2X.png')
    FastImage.resize(icon, 48, 48, outfile: 'watchIcon-38mm-2X.png')
    FastImage.resize(icon, 55, 55, outfile: 'watchIcon-40mm-2X.png')
    FastImage.resize(icon, 58, 58, outfile: 'watchIcon-44mm-2X.png')
    FastImage.resize(icon, 87, 87, outfile: 'watchIcon-44mm-3X.png')
    FileUtils.cp icon, 'Apple-watch-app-store.png'
  end

  # Create iPhone Icons
  Dir.chdir(phone_icons_path) do
    FastImage.resize(icon, 20, 20, outfile: 'Icon-App-20x20@1x.png')
    FastImage.resize(icon, 40, 40, outfile: 'Icon-App-20x20@2x-1.png')
    FastImage.resize(icon, 40, 40, outfile: 'Icon-App-20x20@2x.png')
    FastImage.resize(icon, 60, 60, outfile: 'Icon-App-20x20@3x.png')
    FastImage.resize(icon, 29, 29, outfile: 'Icon-App-29x29@1x-1.png')
    FastImage.resize(icon, 29, 29, outfile: 'Icon-App-29x29@1x.png')
    FastImage.resize(icon, 58, 58, outfile: 'Icon-App-29x29@2x-1.png')
    FastImage.resize(icon, 58, 58, outfile: 'Icon-App-29x29@2x.png')
    FastImage.resize(icon, 87, 87, outfile: 'Icon-App-29x29@3x.png')
    FastImage.resize(icon, 40, 40, outfile: 'Icon-App-40x40@1x.png')
    FastImage.resize(icon, 80, 80, outfile: 'Icon-App-40x40@2x.png')
    FastImage.resize(icon, 80, 80, outfile: 'Icon-App-40x40@2x-1.png')
    FastImage.resize(icon, 120, 120, outfile: 'Icon-App-40x40@3x.png')
    FastImage.resize(icon, 57, 57, outfile: 'Icon-App-57x57@1x.png')
    FastImage.resize(icon, 114, 114, outfile: 'Icon-App-57x57@2x.png')
    FastImage.resize(icon, 120, 120, outfile: 'Icon-App-60x60@2x.png')
    FastImage.resize(icon, 180, 180, outfile: 'Icon-App-60x60@3x.png')
    FastImage.resize(icon, 76, 76, outfile: 'Icon-App-76x76@1x.png')
    FastImage.resize(icon, 152, 152, outfile: 'Icon-App-76x76@2x.png')
    FastImage.resize(icon, 167, 167, outfile: 'Icon-App-83.5x83.5@2x.png')
    FileUtils.cp icon, 'Icon-App-iTunes.png'
  end

else 
  puts 'Image size must be 1024x1024'
  exit 1
end
