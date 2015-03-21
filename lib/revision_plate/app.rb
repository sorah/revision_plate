require 'pathname'

module RevisionPlate
  class App
    def initialize(file = nil, path: nil)
      @file = file
      @path = path
      if @file
        unless @file.kind_of?(Pathname)
          @file = Pathname.new(@file)
        end
      else
        if defined? Rails
          @file = Rails.root.join('REVISION')
        else
          raise ArgumentError, "couldn't locate REVISION file"
        end
      end

      if @file.exist?
        @revision = @file.read.chomp
      else
        @revision = nil
      end
    end

    def call(env)
      unless env['REQUEST_METHOD'] == 'GET' && (@path ? env['PATH_INFO'] == @path : true)
        return [404, {'Content-Type' => 'text/plain'}, []]
      end

      if @revision
        if @file.exist?
          [200, {'Content-Type' => 'text/plain'}, [@revision, ?\n]]
        else
          [404, {'Content-Type' => 'text/plain'}, ["REVISION_FILE_REMOVED\n"]]
        end
      else
        [404, {'Content-Type' => 'text/plain'}, ["REVISION_FILE_NOT_FOUND\n"]]
      end
    end
  end
end
