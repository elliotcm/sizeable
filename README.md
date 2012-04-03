# Sizeable

Sizeable is a low profile Rack app designed to be deployed to [Heroku](http://heroku.com/) which acts as a utility application to handle the resizing of large image assets from S3 on the fly.

Since Heroku employs industrial strength caching; does not charge for bandwidth from Heroku to the world; and does not charge to talk to S3; this is a very low-cost, low-complexity and high-speed solution for asset resizing.

## Setup

Deploy a copy of the app to Heroku.  A simple `heroku apps:create [app-name]` will put you on the supported Bamboo 1.9.2 stack.  Other stacks are currently untested.

Set up your S3 credentials.  You'll need to set the following [config variables](http://docs.heroku.com/config-vars):

* S3_KEY
* S3_SECRET
* S3_BUCKET (optional, you can override the bucket name in the URL)

## Usage
### Basic

If your Sizeable app is deployed to `images.example.com` and you have an image on S3 called `frying-pan.jpg` in the directory `cookware`, the basic form would be:

      http://images.exmaple.com/cookware/frying-pan.jpg

### Additional params

Sizeable also performs resizing and web 2.0 reflection if requested:

      http://images.example.com/additional-assets/more-cookware/reflect/70x70/fancy-frying-pan.png
            S3 bucket ----------------^                           |      ^-------- dimensions (optional)
    (optional if you provided a bucket via config vars)           ^----------- reflection (optional)

Parameters can be provided anywhere in the URL, with the exception of the bucket name.

## Concurrency

Browsers limit the number of asset requests per host, sometimes as low as 2.  If you have many images being loaded from the same host in your page, requests will start blocking and increasing your page load time.

This can be resolved by spreading the images over many hosts.  Sizeable can't do this for you automatically, but it can help.

If you're finding your assets are blocking, try cycling through 3 or 4 hosts, for example:

* images1.example.com
* images2.example.com
* images3.example.com

Since browsers don't require each host to be on a different IP for concurrent requests to take place, the quickest way to implement this on Heroku is to create these hosts as CNAMEs to your main app, and increase your [dyno count](https://devcenter.heroku.com/articles/dynos) to compensate.  Alternatively, you could deploy multiple Heroku apps, one for each host.

## Caching

All images are cached for 14 days.
