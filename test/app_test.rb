require_relative './test_helper'
require 'tmpdir'

require 'revision_plate/app'

class AppTest < Minitest::Spec
  include Rack::Test::Methods
  alias_method :response, :last_response

  describe 'app' do
    let(:app) { RevisionPlate::App.new(file) }
    let(:tmpdir) { Dir.mktmpdir('revision_plate_app_test') }
    let(:file) { Pathname.new(tmpdir).join('REVISION') }

    before do
      File.write file.to_s, "a"
    end

    describe 'with default' do
      let(:app) { RevisionPlate::App.new }

      describe 'with Rails' do
        before do
          RevisionPlate.const_set :Rails, Class.new {
            def self.root
              @root
            end
            def self.root=(o)
              @root = Pathname.new(o)
            end
          }.tap { |klass|
            klass.root = tmpdir
          }
        end

        after do
          RevisionPlate.send :remove_const, :Rails
        end

        it 'returns RAILS_ROOT/REVISION' do
          get '/'
          assert_equal 200, response.status
          assert_equal "a\n", response.body
        end

        describe 'HEAD request' do
          it 'returns 200' do
            head '/'
            assert_equal 200, response.status
            assert_equal '', response.body
          end
        end
      end

      describe 'without Rails' do
        it "raises error" do
          assert_raises(ArgumentError) { app }
        end
      end
    end

    describe 'with path' do
      let(:app) { RevisionPlate::App.new(file, path: '/site/sha') }

      it "won't respond to request to invalid path" do
        get '/site/sha'
        assert_equal 200, response.status
        assert_equal "a\n", response.body

        head '/site/sha'
        assert_equal 200, response.status
        assert_equal "", response.body

        post '/site/sha'
        assert_equal 404, response.status

        get '/site/sha/a'
        assert_equal 404, response.status

        head '/site/sha/a'
        assert_equal 404, response.status

        get '/'
        assert_equal 404, response.status
      end
    end

    it 'returns specified file' do
      get '/'
      assert_equal 200, response.status
      assert_equal "a\n", response.body
    end

    it 'returns same revision even if updated' do
      app # ensure to instantiate
      File.write file.to_s, "b\n"

      get '/'
      assert_equal 200, response.status
      assert_equal "a\n", response.body
    end

    it 'returns 404 for POST request' do
      post '/'
      assert_equal 404, response.status
    end

    it 'returns 200 for HEAD request' do
      head '/'
      assert_equal 200, response.status
      assert_equal '', response.body
    end

    it 'returns 404 if removed' do
      app # ensure to instantiate
      file.unlink

      get '/'
      assert_equal 404, response.status
      assert_equal "REVISION_FILE_REMOVED\n", response.body
    end

    it 'returns 404 for HEAD request if removed' do
      app # ensure to instantiate
      file.unlink

      head '/'
      assert_equal 404, response.status
      assert_equal '', response.body
    end

    it 'returns 404 if not exists' do
      file.unlink
      app # instantiate

      get '/'
      assert_equal 404, response.status
      assert_equal "REVISION_FILE_NOT_FOUND\n", response.body
    end

    it 'returns 404 for HEAD request if not exists' do
      file.unlink
      app # instantiate

      head '/'
      assert_equal 404, response.status
      assert_equal '', response.body
    end

    it 'returns 404 if created but it was not existed' do
      file.unlink
      app # instantiate
      File.write file.to_s, "b\n"

      get '/'
      assert_equal 404, response.status
      assert_equal "REVISION_FILE_NOT_FOUND\n", response.body
    end

    it 'returns 404 for HEAD request if created but it was not existed' do
      file.unlink
      app # instantiate
      File.write file.to_s, "b\n"

      head '/'
      assert_equal 404, response.status
      assert_equal '', response.body
    end
  end
end
