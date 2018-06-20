# README

This is an omniauth2 server provider using devise, doorkeeper, and active-admin to manage the users and applications.

Things you may want to cover:

## Ruby version
2.3.0

## Rails version
4.2.5

## Configuration
If you want to run the application by yourself here are the steps for you.

First you need to clone the [repository from GitHub](https://github.com/diegopiccinini/doorkeeper-provider)

```bash
    git clone git@github.com:diegopiccinini/doorkeeper-provider.git
```

```bash
bundler install
```
### Set the Login with Google+ and the custom domain
We use dotenv-rails to set Google Omniauth and filter by the company domain.
So you have to edit .env as the .env.sample to setup the environment vars, (in production is .evn.production).

```bash

  GOOGLE_CLIENT_ID = "your google client id"

  GOOGLE_CLIENT_SECRET = "your google secret"

  CUSTOM_DOMAIN_FILTER = 'yourdomain.com'

  BACKEND_CALLBACK_URI_PATH= /backend/path/callback

  FRONTEND_CALLBACK_URI_PATH= /frontend/path/callback

```
If you don't have credentials visit to [Google Dev](https://console.developers.google.com) to get your credentials.

## Database creation
The database.yml is linked to external directory

  ln -s ../../config/doorkeeper-provider/database.yml database.yml

Change the file with yours connections set up.

```bash
rake db:create
```

## Database initialization

```bash
rake db:migrate
```
Change the seed.db to add the users, admin users and applications if you want. Then run:

```bash
rake db:seed
```

## Client App
If you want to run the application by yourself here are the steps for
you.

First you need to clone the [repository from GitHub](https://github.com/diegopiccinini/doorkeeper-devise-client)

```bash
    git clone git@github.com:diegopiccinini/doorkeeper-devise-client.git
```
You have to set up the .env values for your app, follow the README file

## Running locally

If you run the client app in port 3000, then you need change the port, and bind the hostname also to have the right uri.
```bash
rails s -p 4000 -b localhost
```

## Running in Production
Important!: to run in production server, I added puma server to config ssl and linked the config/puma.rb file to other directory.

```bash
cd config
ln -s ../../config/doorkeeper-provider/puma.rb puma.rb
```

In puma.rb file for production:

```ruby
threads 8,250
preload_app!
environment 'production'
bind 'ssl://127.0.0.1:4443?key=/path_to_your_key/yourdoomain.key&cert=/path_to_your_cert/yourdomain.crt'
daemonize
```
To run the server
```bash
bundle exec puma -C config/puma.rb
```

Then in your apache you could use proxypass like this:

```xml
<virtualhost *:443>
  servername yourdomain

    sslengine on
    sslprotocol -all +sslv3 +tlsv1
    sslciphersuite rc4-sha:aes128-sha:all:!adh:!exp:!low:!md5:!sslv2:!null
    sslcertificatefile /path_to_your_cert/yourdomain.crt
    sslcertificatekeyfile /path_to_your_key/yourdoomain.key
    sslcertificatechainfile  /path_to_your_cert/yourdomain_bundle.crt

    sslproxyengine on
    sslproxycheckpeercn off
    sslproxycheckpeerexpire off

    proxypreservehost on
    proxypass / https://127.0.0.1:4443/
    proxypassreverse / https://127.0.0.1:4443/
</virtualhost>
```

Enjoy!!
