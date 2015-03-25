require 'revision_plate/app'

module RevisionPlate
  class Middleware
    def initialize(app, path, file = nil, options={})
      @path = path
      @app = app
      @revision_app = App.new(file, **options)
    end

    ACCEPT_METHODS = %w[GET HEAD].freeze

    def call(env)
      if env['PATH_INFO'] == @path && ACCEPT_METHODS.include?(env['REQUEST_METHOD'])
        @revision_app.call(env)
      else
        @app.call(env)
      end
    end
  end
end
