require 'pathname'

module RevisionPlate
  class App
    def initialize(file = nil, path: nil)
      @file = file
      @path = path
      @heroku_slug_commit = ENV["HEROKU_SLUG_COMMIT"]

      if @file
        unless @file.kind_of?(Pathname)
          @file = Pathname.new(@file)
        end
      else
        if defined? Rails
          @file = Rails.root.join('REVISION')
        elsif @heroku_slug_commit.nil?
          raise ArgumentError, "couldn't locate REVISION file"
        end
      end

      if @file.exist?
        @revision = @file.read.chomp
      elsif @heroku_slug_commit
        @revision = @heroku_slug_commit
      else
        @revision = nil
      end
    end

    ACCEPT_METHODS = ['GET', 'HEAD'].freeze

    def call(env)
      unless ACCEPT_METHODS.include?(env['REQUEST_METHOD']) && (@path ? env['PATH_INFO'] == @path : true)
        return [404, {'Content-Type' => 'text/plain'}, []]
      end

      if @revision
        if @file.exist? || @heroku_slug_commit
          status = 200
          body = [@revision, ?\n]
        else
          status = 404
          body = ["REVISION_FILE_REMOVED\n"]
        end
      else
        status = 404
        body = ["REVISION_FILE_NOT_FOUND\n"]
      end

      headers = {'Content-Type' => 'text/plain'}
      if env['REQUEST_METHOD'] == 'HEAD'
        [status, headers, []]
      else
        [status, headers, body]
      end
    end
  end
end
