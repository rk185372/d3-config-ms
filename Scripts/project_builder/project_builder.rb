require 'json'

class ProjectBuilder
    INCLUDE_WATCH_APP_KEY = "includesWatchApp"
    INCLUDE_TODAY_EXTENSIONS_KEY = "includesTodayExtensions"
    def initialize()
        filename = "#{Dir.pwd}/environment/config/buildFlags.json"
        if File.file?(filename)
            file = File.read(filename)
            @flags = JSON.parse(file)
            puts "-------------------------"
            puts "Using custom build flags:"
            puts "-------------------------"
            puts JSON.pretty_generate(@flags)
            puts "-------------------------"
        else
            @flags = {}
            puts "-------------------------"
            puts "No custom build flags"
            puts "-------------------------"
        end
    end

    def build(isCIServer)
        build_podfile(isCIServer)
        build_project_file
    end

    private
    
    def build_podfile(isCIServer)
        generated_podfile = "#{Dir.pwd}/Podfile"
        base_podfile = "#{__dir__}/base_podfile.rb"
        watch_target = File.read("#{__dir__}/watch_podfile_target.rb")
        today_targets = File.read("#{__dir__}/today_podfile_targets.rb")
        
        FileUtils.cp base_podfile, generated_podfile
        
        include_watch = @flags[INCLUDE_WATCH_APP_KEY] != false
        include_today = @flags[INCLUDE_TODAY_EXTENSIONS_KEY] != false

        to_write = ""
        if include_watch
            to_write = watch_target
        else
            to_write = ""
        end

        if isCIServer
            IO.write(generated_podfile, File.open(generated_podfile) { |f| 
                f.read.gsub('https://bitbucket.org/ondot_robo/ondot-podspecs', 'git@bitbucket.org:ondot_robo/ondot-podspecs.git')
            })
        end

        IO.write(generated_podfile, File.open(generated_podfile) { |f| 
            f.read.gsub('# Watch_App', to_write)
        })
        
        if include_today
            to_write = today_targets
        else
            to_write = ""
        end

        IO.write(generated_podfile, File.open(generated_podfile) { |f| 
            f.read.gsub('# Today_Extensions', to_write)
        })
    end

    def build_project_file() 
        podfile_extensions = "#{Dir.pwd}/PodfileExtensionRemote.rb"
        generated_project = "#{Dir.pwd}/project.yml"
        base_project = "#{__dir__}/base_project.yml"
        watch_target = File.read("#{__dir__}/watch_target.yml")
        today_targets = File.read("#{__dir__}/today_targets.yml")
        today_dependencies = File.read("#{__dir__}/today_dependencies.yml")
        watch_dependencies = File.read("#{__dir__}/watch_dependencies.yml")
        notification_targets = File.read("#{__dir__}/notification_targets.yml")
        notification_dependencies = File.read("#{__dir__}/notification_dependencies.yml")

        FileUtils.cp base_project, generated_project
        
        include_watch = @flags[INCLUDE_WATCH_APP_KEY] != false
        include_today = @flags[INCLUDE_TODAY_EXTENSIONS_KEY] != false
        include_notifications = false 

        # Can be uncommented if we want to implement notifications through OnDot
        # File.open podfile_extensions do |file|
        #     file.find { |line| 
        #         if line =~ /.*CardControl\/OnDot.*/
        #             puts "OnDot found: Adding notification targets"
        #             include_notifications = true
        #         end
        #     }
        # end

        to_write = ""
        if include_watch
            to_write = watch_target
        else
            to_write = ""
        end

        IO.write(generated_project, File.open(generated_project) { |f| 
            f.read.gsub('# Watch_App', to_write)
        })
        
        if include_today
            to_write = today_targets
        else
            to_write = ""
        end

        IO.write(generated_project, File.open(generated_project) { |f| 
            f.read.gsub('# Today_Extensions', to_write)
        })

        if include_today
            to_write = today_dependencies
        else
            to_write = ""
        end
            
        IO.write(generated_project, File.open(generated_project) { |f| 
            f.read.gsub('# Today_Dependencies', to_write)
        })

        to_write = ""
        if include_watch
            to_write = watch_dependencies
        else
            to_write = ""
        end

        IO.write(generated_project, File.open(generated_project) { |f| 
            f.read.gsub('# Watch_Dependencies', to_write)
        })

        to_write = ""
        if include_notifications
            to_write = notification_targets
        else
            to_write = ""
        end

        IO.write(generated_project, File.open(generated_project) { |f| 
            f.read.gsub('# Notification_Extensions', to_write)
        })

        to_write = ""
        if include_notifications
            to_write = notification_dependencies
        else
            to_write = ""
        end

        IO.write(generated_project, File.open(generated_project) { |f| 
            f.read.gsub('# Notification_Dependencies', to_write)
        })

        if include_watch || include_today || include_notifications
            IO.write(generated_project, File.open(generated_project) { |f| 
                f.read.gsub('#dependencies', 'dependencies')
            })
        end
    end
end