Quanto Plugins
======

This repository contains the Quanto plugin server.
The plugin server runs a number of plugins that all send data to Quanto.

To run this project, first make sure you have ruby 2.0 installed.
Then clone the repository and in the `quanto` directory, execute:

```
  bundle install
```

In addition to installing the required gems (which bundle install will handle for you), you also want to install the following dependencies:

- Postgres (database)
- Redis (key-value store, used for background jobs)

After installing Postgres, create a new user for your database and bring the database up to speed:

```
 createuser -s -r quanto
 rake db:create:all
 rake db:migrate
```

That will create a database user for you, create the required databases, and load the current schema.
Note that actually running the server requires a number of environment variables to be set.
You should get the `.ENV` file from Rasmus
Once you have the environment variables set up, you can run the server by executing:

```
foreman start
```

## Opening Credits

The following gems and tools make the Quanto plugins possible:

- Postgres (our database)
- Unicorn (production-grade webserver)
- Redis (key-value store, used in all background jobs)
- Sidekiq (ruby gem for managing background jobs)
- [`omniauth`](https://github.com/intridea/omniauth) (framework for easy OAuth integration with 3rd party APIs and of course Quanto)
- [`fitgem`](https://github.com/whazzmaster/fitgem),
  [`lastfm`](https://github.com/youpy/ruby-lastfm),
  [`koala`](https://github.com/arsduo/koala),
  [`twitter`](https://github.com/sferik/twitter),
  [`moves`](https://github.com/ankane/moves),
  [`instagram`] (https://github.com/Instagram/instagram-ruby-gem)(3rd party API gems)

## Whirlwind Tour

This section will walk you through the anatomy of a Quanto plugin.
First, we begin with some terminology:

### Models

- [`OauthKey`](https://github.com/rasmusrygaard/quanto-plugins/tree/master/app/models/oauth_key.rb)

    A representation of a set of OAuth credentials.
    Each `OauthKey` stores which 3rd party API it belongs to along with any credentials and identifiers for that service.
    Note that `OauthKey`s store credentials for both "regular" 3rd party services and Quanto.

- [`Mapping`](https://github.com/rasmusrygaard/quanto-plugins/tree/master/app/models/mapping.rb)

    A `Mapping` is a pair of `OauthKeys`.
    In particular, a `Mapping` pairs a set of Quanto credentials (`quanto_key`) with a set of 3rd party API credentials (`api_key`).
    This model makes it easy to decide which Quanto user to record data for when polling the 3rd party APIs.

---

### Setting up Credentials

Now we are ready to design a plugin.
The first thing we need is to set up the `omniauth` credentials.
`omniauth` credentials let us initiate a request for credentials simply by visiting a fixed URL like `/auth/facebook/` (known as a request path).
Visiting that URL, for instance, will send you to Facebook to ask for permissions to let Quanto access your data.
Each plugin also has its own set of Quanto credentials, and we need to set up separate request paths for each plugin, so Quanto knows which plugin is requesting credentials.
The credentials are sent to `/auth/facebook/callback` or to whatever URL we specify as `callback_path`.
This is all done in the [OmniAuth initializer](https://github.com/rasmusrygaard/quanto-plugins/tree/master/config/initializers/omniauth.rb)

Notice that all Quanto credentials to go `/auth/quanto/:provider/callback`.
This lets us grab all the credentials in the `QuantoKeyController` described below.
It is also important to note the distinction between application ids and secrets and user access tokens.
The application credentials identify the plugin while the user credentials identify the user for that plugin.
`ENV["FACEBOOK_KEY"]` and `ENV["FACEBOOK_SECRET"]` are our Facebook application key and secret, but we need an access token for a particular user before we can request data.

### Getting Quanto Access Tokens

First, however, we need access tokens for Quanto.
These are obtained by visiting `/auth/quanto/:provider` where `:provider` is the name of a plugin.
Thanks to OmniAuth, this request will redirect for Quanto, where the user will be prompted to allow the given plugin to send data.

After allowing the plugin, the user's credentials are sent back to Quanto by sending a `HTTP POST` to `/auth/quanto/:provider/callback`.
All of these requests go to the `QuantoKeyController`, which then does four things:

1. Create an `OauthKey` with the Quanto credentials.
    The credentials are set by OmniAuth in `request.env['omniauth.auth']`:

2. Create a temporary `Mapping` (only with a Quanto Key)

3. Set the ID of the newly created Quanto credentials in the session.
    This will let us find the right `Mapping` easily when we get 3rd party credentials.

4. Initiate the request for 3rd party credentials by redirecting to `/auth/:provider`.

### Getting 3rd Party Access Tokens

After the redirect, we obtain 3rd party credentials much like described above.
The callback for each provider goes to a `KeyController` like `FacebookKeyController` or `FitbitKeyController`.
When accepting the callback, the controller does the following:

1. Create an `OauthKey` with the 3rd party credentials.
2. Calls [`Mapping.create_mapping_for_key`](https://github.com/rasmusrygaard/quanto-plugins/blob/master/app/models/mapping.rb#L19) to map the new key to the Quanto key stored in step 3 in the previous section.
    This call also requests 3rd party data for the given provider asynchronously so the plugin immediately has data after being activated.
3. Creates a Quanto::Client (a Quanto API client) and activates the plugin.
    Activating the plugin simply tells Quanto that the plugin got all credentials successfully and is ready to send data.
    Without that call, the plugin would get deactivated after a few minutes.

### Sending Data

The plugin now has data for both Quanto and any required 3rd party APIs.
We are ready to start sending data!
To keep everything speedy, the plugin server collects and sends data asynchronously in background workers.
The workers are all in `app/workers`.
Each worker is required to implement two methods:

**[`#perform(mapping_id)`](https://github.com/rasmusrygaard/quanto-plugins/blob/master/app/workers/instagram_worker.rb#L4)**

This gets an identifier for a `Mapping`, looks up both Quanto and 3rd party credentials.
For example, here is an annotated `InstragramWorker#perform(mapping_id)` method:

First, we find the mapping and abort if we are missing either set of credentials.

```ruby
mapping = Mapping.find(mapping_id)
return if mapping.quanto_key.nil? || mapping.api_key.nil?
```

Then, we create clients for both Quanto and Instagram.

```ruby
client = Instagram.client(access_token: mapping.api_key.token)
quanto_key = mapping.quanto_key

begin
  quanto_client = Quanto::Client.new(ENV["QUANTO_INSTAGRAM_KEY"], ENV["QUANTO_INSTAGRAM_SECRET"],
                                     access_token: mapping.quanto_key.token)
```

We then get data from Instagram by calling the `.user` method, which gives us a quick summary of the user's data.
This data is then sent to Quanto by calling `record_entry` passing first the value to record and second which metric the value belongs to.

```ruby
  user = client.user
  quanto_client.record_entry(user.counts.media, :photos)
  quanto_client.record_entry(user.counts.followed_by, :followers)
  quanto_client.record_entry(user.counts.follows, :following)
```

Finally, Quanto users can of course disable plugins too.
In that case, our access token gets revoked, and we get an `Oauth2::Error` whenever we attempt to send credentials with the revoked token.
To avoid piling up invalid credentials, we mark the `Mapping` as invalid and notify NewRelic of the error to keep some stats.

```ruby
rescue OAuth2::Error => e
  # This is most likely happening because of invalid Quanto credentials. In that case, mark
  # the mapping as invalid and move on.
  mapping.invalidate!
  NewRelic::Agent.agent.error_collector.notice_error(e, metric: 'instagram')
end
```

**[`.perform_all()`](https://github.com/rasmusrygaard/quanto-plugins/blob/master/app/workers/instagram_worker.rb#L30)**

`perform_all` simply executes `perform` asynchronously for every `Mapping` for the given API.

---

To send data continuously, we call `perform_all` on every worker every hour.
The actual timing and scheduling is handled by the Heroku Scheduler.
