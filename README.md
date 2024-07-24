# Livre

Welcome on my demo project. This is a barely working mini-facebook.

You can login using Google. Once logged in, you will end up on the feed where you can write posts and comment on your friend's posts.

You can search for existing users on the search bar and add them as friends.

You will also receive notifications when you get a new friend request or when you feed has been updated (new post or comments).

## Install

```
mix deps.get
mix ecto.setup
```

## Run locally

```
source GOOGLE_CLIENT_SECRET=<GOOGLE_SECRET_SHARED_BY_EMAIL>
mix phx.server
```

## Run test

The code in `lib/livre` is almost fully covered using DocTests.
However I didn't have time to properly test the the main liveviews

```
mix test
```

## Architectures & Decisions (with some hot takes)

 - I mostly follow Elixir/Phoenix's standard
 - I've favored Google SSO over `phx.gen.auth` because I find the later to add way too much files for a small project like this one
 - I'm not a big fan of meta-prog but I've been using it a bit to really highlight module that do SQL query (see Livre.Repo.Query)
 - I'm using contextes but still group all my schemas in `lib/livre/repo`. Otherwise I find it hard to differenciate between schema and normal modules
 - I tend to avoid too comments inside function, instead I use meaningful names
 - I prefer to user guards rather than specs