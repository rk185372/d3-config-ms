require_relative 'script_helper_factory'

raise('template_id must be passed in as the first argument.') if ARGV[0].nil?

template_id = ARGV[0].to_i

script_helper = create_script_helper
script_helper.set_active_template(template_id)
