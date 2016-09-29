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

  GOOGLE_CLIENT_ID = "your google client id"
  GOOGLE_CLIENT_SECRET = "your google secret"
  CUSTOM_DOMAIN_FILTER = 'yourdomain.com'

If you don't have credentials visit to [Google Dev](https://console.developers.google.com) to get your credentials.

## Database creation

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

## Run
If you run the client app in port 3000, then you need change the port, and bind the hostname also to have the right uri.
```bash
rails s -p 4000 -b localhost
```

Enjoy!!
