# Mentioned on the BBC

Playing around with topics extracted from live subtitles from BBC channels.

The app is a fairly lightweight affair. It's Rails, no tests or anything because it's a proof of concept and not intended for use anywhere, really.

You need to install on your box:

* Ruby/Rails (Ruby 1.9.x)
* MongoDB
* All the gem dependencies (bundle install)

You also need to ensure you run `rake db:mongoid:create_indexes` and `rake db:seed` prior to doing anything with the site; the geographic queries in MongoDB won't work unless the index exists and it won't be automatically created in the production environment.

There's a background processor: `rake mentions:update` will ping the live topics API every 5 minutes and check the latest 5 mins worth of topics against dbpedia. Anything with a location will get stored.

Unicorn is included in the Gemfile for application servering. Pair with nginx, season lightly with varnish if you feel keen, and leave for a few hours to get some data.
