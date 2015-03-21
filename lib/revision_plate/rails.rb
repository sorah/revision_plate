require 'revision_plate'

if defined?(Rails)
  module RevisionPlate
    class Railtie < Rails::Railtie
      initializer "revision_plate.rails_middleware" do |app|
        app.middleware.use RevisionPlate::Middleware, '/site/sha'
      end     
    end
  end
end
