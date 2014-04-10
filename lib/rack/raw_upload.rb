module Rack
  class RawUpload

    def initialize(app, opts = {})
      @app = app
      @paths = opts[:paths] #optional upload path
      @paths = [@paths] if @paths.kind_of?(String)
    end

    def call(env)
      raw_file_post?(env) ? convert_and_pass_on(env) : @app.call(env)
    end

    def upload_path?(request_path)
      return true if @paths.nil?

      @paths.any? do |candidate|
        literal_path_match?(request_path, candidate) || wildcard_path_match?(request_path, candidate)
      end
    end


    private

    def convert_and_pass_on(env)
      if env['rack.input'].kind_of?(Tempfile)
        tempfile = env['rack.input']
      else
        tempfile = Tempfile.new('raw-upload.')
        tempfile = open(tempfile.path, "r+:BINARY")
        tempfile << env['rack.input'].read
        tempfile.flush
        tempfile.rewind
      end

      fake_file = {
        :filename => env['HTTP_X_FILE_NAME'],
        :type => 'application/octet-stream',
        :tempfile => tempfile,
      }
      env['rack.request.form_input'] = env['rack.input']
      env['rack.request.form_hash'] ||= {}
      env['rack.request.query_hash'] ||= {}
      env['rack.request.form_hash']['file'] = fake_file
      env['rack.request.query_hash']['file'] = fake_file
      if query_params = env['HTTP_X_QUERY_PARAMS']
        require 'json'
        params = JSON.parse(query_params)
        env['rack.request.form_hash'].merge!(params)
        env['rack.request.query_hash'].merge!(params)
      end
      @app.call(env)
    end

    def raw_file_post?(env)
      upload_path?(env['PATH_INFO']) &&
        env['REQUEST_METHOD'] == 'POST' &&
        env['CONTENT_TYPE'] == 'application/octet-stream' &&
        !env['HTTP_X_FILE_NAME'].nil? && 
        !env['HTTP_X_FILE_NAME'].empty?
    end

    def literal_path_match?(request_path, candidate)
      candidate == request_path
    end

    def wildcard_path_match?(request_path, candidate)
      return false unless candidate.include?('*')
      regexp = '^' + candidate.gsub('.', '\.').gsub('*', '[^/]*') + '$'
      !! (Regexp.new(regexp) =~ request_path)
    end
  end
end
