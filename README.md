# Tradewinds

![AWS build badge](https://codebuild.us-east-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiM1ZDOUVNMW9mSXRiWmFGelpCYmNETXVQcnhHWFBNNWVIYmlPOTMwelhud2N3bWg0bjdVUzF6NlVZSGFlSlNUazB3MllIRHh6ekNab2M1Q1FFS2wvUGUwPSIsIml2UGFyYW1ldGVyU3BlYyI6InJhUmN2S0UzNHNndVp6STUiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)


### CI

The CI server on AWS, us-east-2 is built by using the terraform found at ${project_root}/infrastructure/build_pipeline

To build the CI service:
1) `tfa -var-file="infrastructure/build_pipeline/terraform/terraform.tfvars" infrastructure/build_pipeline/terraform/`
2) Log in and authorize github access, choose the project from the authorized github repo
3) Setup the webhook

The codebuild image is built from the docker portion of the build_pipline.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
