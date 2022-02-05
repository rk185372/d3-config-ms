require_relative 'script_helper'

def create_script_helper
    jarvis_token = ENV['JARVIS_TOKEN']
    
    if jarvis_token.nil? || jarvis_token.empty?
        raise 'Jarvis token is not set. Set it via `export JARVIS_TOKEN=secret`.'
    end
    
    ScriptHelper.new(jarvis_token, 'https://jarvis.d3vcloud.com/api/')
end
