require 'optparse'

options = {}
parser = OptionParser.new do |opts|
    opts.banner = "Usage: build_local_web.rb [options]"

    opts.on("-w", "--webpath=STRING", "Web Path") do |webPath|
        options[:webPath] = webPath
    end

    opts.on('-f', "--features=STRING", "The Features To Build") do |features|
        options[:features] = features
    end
end

# Parse the command line options.
parser.parse!

# Change to the local web repo and build the features
# passed into the command line.
Dir.chdir(options[:webPath]) do
    featuresString = ""

    options[:features].split(',').each do |feature|
        featuresString += "--feature #{feature} "
    end

    featuresString.strip!

    system("yarn build --mobile ios #{featuresString}")
end

Dir.entries("#{options[:webPath]}/dist").each do |name| 
    unless name == '.' || name == '..'
        source = "#{options[:webPath]}/dist/#{name}"
        dest = "./webComponents/#{name}"

        if File.directory?(source)
            source += '/'
        end

        system("cp -R #{source} #{dest}")
    end
end

