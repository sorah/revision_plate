require_relative './test_helper'
require 'tempfile'

require 'revision_plate/middleware'

module RevisionPlate
  AppOriginal = App
end

class AppTest < Minitest::Spec
  include Rack::Test::Methods
  alias_method :response, :last_response

  describe 'middleware' do
    let(:tempfile) { Tempfile.new('revision_plate-middielware-test') }

    let(:nextapp) { -> (env) { [200, {'content-type' => 'text/plain'}, ['hi']] } }
    let(:mockapp) do
      Class.new do
        def self.instances
          @instances ||= []
        end

        def initialize(file, **options)
          @file = file
          @options = options
          self.class.instances << self
        end

        attr_reader :file, :options

        def call(env)
          [200, {'content-type' => 'text/plain'}, "deadbeef"]
        end

        const_set(:ACCEPT_METHODS, %w[GET HEAD].freeze)
      end
    end

    let(:app) { RevisionPlate::Middleware.new(nextapp, '/site/sha', tempfile.path, opt: :option) }

    before do
      RevisionPlate.send(:remove_const, :App)
      RevisionPlate.const_set(:App, mockapp)
    end

    after do
      RevisionPlate.send(:remove_const, :App)
      RevisionPlate.const_set(:App, RevisionPlate::AppOriginal)
    end

    it 'instantiates App with proper argument' do
      app

      assert_equal 1, mockapp.instances.size
      assert_equal({opt: :option}, mockapp.instances.first.options)
      assert_equal tempfile.path, mockapp.instances.first.file
    end

    it 'pass-through requests to nextapp' do
      get '/'
      assert_equal 'hi', response.body
      post '/'
      assert_equal 'hi', response.body
      get '/site'
      assert_equal 'hi', response.body
      post '/site/sha'
      assert_equal 'hi', response.body
    end

    it 'pass requests to RevisionPlate::App on specific path' do
      get '/site/sha'
      assert_equal 'deadbeef', response.body

      head '/site/sha'
      assert_equal 200, response.status
      assert_equal 'deadbeef', response.body
    end
  end
end

