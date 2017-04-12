module BlocWorks
  class Application
    def controller_and_action(env)

      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"
      controller = Object.const_get(controller)
      controller_instance = controller.new(env)
      [200, {'Content-Type' => "#{controller}"}, [controller_instance.send(action.to_sym)]]

    end

    def fav_icon(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end

    def route(&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      if @router.nil?
        raise "No routes defined"
      end

      @router.look_up_url(env["PATH_INFO"])
    end
  end

  class Router
    def initialize
      @rules = []
    end


    def map(url, *args)
      # refactored #map
  		# options, destination = map_options(*args)
  		# regex, vars = map_parts(url)
      #
  		# @rules.push({ regex: Regexp.new("^/#{regex}$"),
  		# 							vars: vars,
  		# 							destination: destination,
  		# 							options: options})
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}

      destination = nil
      destination = args.pop if args.size > 0
      raise "Too many args!" if args.size > 0

      parts = url.split("/")
      parts.reject! { |part| part.empty? }

      vars, regex_parts = [], []

      parts.each do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          regex_parts << "(.*)"
        else
          regex_parts << part
        end
      end
      regex = regex_parts.join("/")
      @rules.push({ regex: Regexp.new("^/#{regex}$"),
                    vars: vars, destination: destination,
                    options: options })
  	end

    def map_options(*args)
  	  options, destination = {}, nil
  		if args[-1].is_a? Hash
  			options = args.pop
  		end
  		options[:default] ||= {}

  		if args.size > 0
  			destination = args.pop
  			if args.size > 0
  				raise 'Too many args'
  			end
  		end
  		return options, destination
  	end

    def map_parts(url)
  		regex_parts, vars = [], []
  		parts = url.split("/").delete_if { |part| part.empty? }

  		parts.each do |part|
  			if part[0] == ":"
  				vars << part[1..-1]
  				regex_parts << "([a-zA-Z0-9]+)"
  			elsif part[0] == "*"
  				vars << part[1..-1]
  				regex_parts << "(.*)"
  			else
  				regex_parts << part
  			end
  		end

  		return regex_parts.join("/"), vars
  	end


    def look_up_url(url)
      # refactored #look_up
  	  # @rules.each do |rule|
  		#   rule_match = rule[:regex].match(url)
      #
  		# 	if rule_match
  		# 		options = rule[:options]
  		# 		params = set_params(options, rule_match, rule)
  		# 		return set_destination(rule, params)
  		# 	end
  		# end
      @rules.each do |rule|
        rule_match = rule[:regex].match(url)

        if rule_match
          options = rule[:options]
          params = options[:default].dup

          rule[:vars].each_with_index do |var, index|
            params[var] = rule_match.captures[index]
          end

          if rule[:destination]
            return get_destination(rule[:destination], params)
          else
            controller = params["controller"]
            action = params["action"]
            return get_destination("#{controller}##{action}", params)
          end
        end
      end
  	end

    def set_params(options, rule_match, rule)
  		params = options[:default].dup

  		rule[:vars].each_with_index do |var, index|
  			params[var] = rule_match.captures[index]
  		end

  		params
  	end

  def set_destination(rule, params)
		if rule[:destination]
			return get_destination(rule[:destination], params)
		else
		  return get_destination("#{params["controller"]}##{params["action"]}", params)
		end
	end

    def get_destination(destination, routing_params = {})
      if destination.respond_to?(:call)
        return destination
      end


      if destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        return controller.action($2, routing_params)
      end
      raise "Destination not found: #{destination}"
    end

    def resources(controller)
  		actions = create_resourceful_array
  		actions.each do |action|
  			map action.first, action.last
  		end
  	end

  	def create_resourceful_array
  		actions = []
  		actions << [":controller", default: {"action" => "index", "request_method" => "get"}]
  		actions << [":controller/:id", default: {"action" => "show", "request_method" => "get"}]
  		actions << [":controller/:action", default: {"action" => "new", "request_method" => "get"}]
  		actions << [":controller", default: {"action" => "create", "request_method" => "post"}]
  		actions << [":controller/:id/:action", default: {"action"=>"edit", "request_method" => "get"}]
  		actions << [":controller/:id", default: {"action" => "update", "request_method" => "put"}]
  		actions << [":controller/:id", default: {"action" => "delete", "request_method" => "delete"}]
  		actions
  	end
  end
end
