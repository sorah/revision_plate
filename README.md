# RevisionPlate

Rack application and middleware that serves endpoint returns application's `REVISION`.

## Detail

The endpoint returns content of `REVISION`

Content of the endpoint wouldn't be changed even if `REVISION` file has changed. But it'll return 404 when it has removed.

This can be used for health check + remove from service by hand.

This gem is used in [Cookpad](https://info.cookpad.com/).
And seems several companies runs similar thing (e.g. [GitHub](https://github.com/blog/609-tracking-deploys-with-compare-view)).

## Usage

### typical Rails app

``` ruby
# Gemfile
gem 'revision_plate', require: 'revision_plate/rails'
```

then your Rails application will handle `/site/sha`.

### rack application

``` ruby
# Gemfile
gem 'revision_plate'

# config.ru (middleware)
use RevisionPlate::Middleware, '/site/sha', "#{__dir__}/REVISION"

# config.ru (mount)
map '/site/sha' do
  run RevisionPlate::App.new("#{__dir__}/REVISION")
end
```

## Test

```
$ echo 'deadbeef' > REVISION
$ (... start your app ...)
$ curl localhost:3000/site/sha
deadbeef
$ rm REVISION
$ curl localhost:3000/site/sha
REVISION_FILE_REMOVED
```

## Advanced

### I want to customize (Rails app)

remove `require: 'revision_plate/rails'` from Gemfile, then initialize `RevisionPlate::App` on routes:

```
# routes.rb
get '/site/sha' => RevisionPlate::App.new
get '/site/sha' => RevisionPlate::App.new("/path/to/my/favorite/REVISION")
```

### heroku suppor

revision_plate reads the environment variable HEROKU_SLUG_COMMIT.

https://devcenter.heroku.com/articles/dyno-metadata

```
$ heroku labs:enable runtime-dyno-metadata -a <app name>
```

## Development

### Testing

```
$ rake test
```

## License

MIT License
