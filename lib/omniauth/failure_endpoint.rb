module OmniAuth
  # This simple Rack endpoint that serves as the default
  # 'failure' mechanism for OmniAuth. If a strategy fails for
  # any reason this endpoint will be invoked. The default behavior
  # is to redirect to `/auth/failure` except in the case of
  # a development `RACK_ENV`, in which case an exception will
  # be raised.
  class FailureEndpoint
    attr_reader :env

    def self.call(env)
      new(env).call
    end

    def initialize(env)
      @env = env
    end

    def call
      raise_out! if ENV['RACK_ENV'].to_s == 'development'
      redirect_to_failure
    end

    def raise_out!
      raise env['omniauth.error'] || OmniAuth::Error.new(env['omniauth.error.type']) 
    end

    def redirect_to_failure
      message_key = env['omniauth.error.type']
      new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}"
      Rack::Response.new(["302 Moved"], 302, 'Location' => new_path).finish
    end
  end
end