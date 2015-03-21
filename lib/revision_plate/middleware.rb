require 'revision_plate/app'

module RevisionPlate
  class Middleware
    def initialize(app, path, file = nil, options={})
      @path = path
      @app = app
      @revision_app = App.new(file, **options)
    end

    def call(env)
      if env['PATH_INFO'] == @path && env['REQUEST_METHOD'] == 'GET'
        @revision_app.call(env)
      else
        @app.call(env)
      end
    end
  end
end
