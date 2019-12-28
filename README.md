# Tradewinds

![AWS build badge](https://codebuild.us-east-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoicXRVZnBQcVorU2YxMUR4SzE3VE43T25GdktWN3FGTjZlaWhBaE5hbEl1YURzbjVCVVhkUUt1NnhlNU9pZEcxWUFLT1VnOUZtb1BjdThVZENrOXdxNGlFPSIsIml2UGFyYW1ldGVyU3BlYyI6Inp0bzY0YjBFWTRQVlE1YSsiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)


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
