Sizeable
========

Sizeable is a low profile Rack app designed to be deployed to Heroku.

It acts as a utility application to handle the resizing of large image assets from S3 on the fly.

Because Heroku employs industrial strength caching, does not charge for bandwidth from Heroku to the world and does not charge to talk to S3, this is a very low-cost, low-complexity and high-speed solution for asset resizing.

Usage
-----

Deploy a copy of the app to [Heroku](http://heroku.com/).  You'll need to deploy to the [Aspen stack](http://docs.heroku.com/stack) and use the `.gems` manifest instead of a `Gemfile` for RMagick's sake.

Set up your S3 credentials.  You'll need to set the following [config variables](http://docs.heroku.com/config-vars):

* S3_KEY
* S3_SECRET
* S3_BUCKET

When you feed your images out into your primary app, simply add the S3 path to the image onto the end of the URL to your Sizeable app.

For example, if your Sizeable app is deployed to `images.example.com` and you have an image on S3 called `frying-pan.jpg` in the directory `cookware`, provide your users with the URL `http://images.example.com/cookware/frying-pan.jpg`.

To limit that image to 100px tall by 75px wide while maintaining aspect ratio, you would use `http://images.example.com/cookware/frying-pan.jpg?height=100&width=75`.

All images are cached for 14 days.

To pay or not to pay
--------------------

Sizeable will work perfectly well on a Heroku free app, but if your site has even moderate concurrency you're going to have to deal with that somehow.

You could run up a few free apps and round-robin from your primary application, but this requires added complexity and maintenance overheads.  Your apps will also not share a cache, so your users could experience some additional slow-loading pages.
