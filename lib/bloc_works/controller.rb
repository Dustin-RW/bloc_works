require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      text = self.send(action)
      if has_response?
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    #invoke controller action
    def self.action(action, response = {})
      proc { |env| self.new(env).dispatch(action, response) }
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params.merge(@routing_params)
    end


    def response(text, status = 200, headers = {})
      raise "Cannot respond multiple times" unless @response.nil?
      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def render(*args)
			response(create_response_array(*args))
    end


    def get_response
      @response
    end

    def has_response?
      !@response.nil?
    end

    def create_response_array(view, locals = {})

      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")

      template = File.read(filename)
      eruby = Erubis::Eruby.new(template)

		  # get instance variables from controller
      self.instance_variables.each do |inst_var|
        puts "inst_var : #{inst_var}"
        inst_var_value = self.instance_variable_get(inst_var)
        # set them as eruby instance variables
        # eruby.instance_variable_set(inst_var, inst_var_value)
        locals[inst_var[1..-1]] = inst_var_value
      end

      eruby.result(locals.merge(env: @env))
    end

    # convert a string like LabelsController to labels
    def controller_dir
      klass = self.class.to_s
      klass.slice!("Controller")
      BlocWorks.snake_case(klass)
    end

    #implent redirect for controller actions
    def redirect(target, status="302", routing_params={})
			if status == "302"
				if self.respond_to? target
					routing_params['controller'] = self.class.to_s.split('Controller')[0].downcase
					routing_params['action'] = target.to_s
					dispatch(target, routing_params)
				elsif target =~ /^([^#]+)#([^#]+)$/
					controller = $1
					action = $2
					routing_params = {"action" => action, "controller" => controller}
					name = controller.capitalize
					controllerName = Object.const_get("#{name}Controller")
					controllerName.dispatch(action, routing_params)
				else
					response("", "302", {"Location" => target})
				end
			else
				puts "Incorrect status code supplied for redirect"
			end
		end
  end
end
