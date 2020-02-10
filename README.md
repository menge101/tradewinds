# Tradewinds

![AWS build badge](https://codebuild.us-east-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoicXRVZnBQcVorU2YxMUR4SzE3VE43T25GdktWN3FGTjZlaWhBaE5hbEl1YURzbjVCVVhkUUt1NnhlNU9pZEcxWUFLT1VnOUZtb1BjdThVZENrOXdxNGlFPSIsIml2UGFyYW1ldGVyU3BlYyI6Inp0bzY0YjBFWTRQVlE1YSsiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

### Development

This application uses a local DynamoDB service for testing and development.  
There is a convenience script @ ./scripts/start_dynamo_local.sh for starting the service.

### CI

The CI server on AWS, us-east-2 is built by using the terraform found at ${project_root}/infrastructure/build_pipeline

#### CI Build Image
The CI build image is created from a Dockerfile in `infrastructure/build_pipeline/docker/Dockerfile`

The first thing to do is to update the `pipeline_build_image_version.txt` file with the new version to be of the docker image.
ECR is configured with immutable image tags, so a new image with an already existing tag will be rejected.

If you have the [semvar utility](https://github.com/fsaintjacques/semver-tool) installed, the script will automatically bump the version for you.

There is a convenience script located with it that will build the image, properly tag it, and push it to ECR.
It should be called from the project root, like this: `./infrastructure/build_pipeline/docker/build_n_push_pipeline_image.sh`

With that complete, you can now build the 

#### CI Service

Initial build of the CI service:
1) Run `TF_VAR_codebuild_image_version=$(cat infrastructure/build_pipeline/docker/pipeline_build_image_version.txt) tfa -var-file="infrastructure/build_pipeline/terraform/terraform.tfvars" infrastructure/build_pipeline/terraform/`
2) Log in and authorize github access, choose the project from the authorized github repo
3) Setup the webhook

To update the CI service to use a new build image run:  
`TF_VAR_codebuild_image_version=$(cat infrastructure/build_pipeline/docker/pipeline_build_image_version.txt) tfa -var-file="infrastructure/build_pipeline/terraform/terraform.tfvars" infrastructure/build_pipeline/terraform/`

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
