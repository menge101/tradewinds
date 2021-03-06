#!/usr/bin/env bash

pipeline_path="$(pwd)/infrastructure/build_pipeline/docker"
version_path="$pipeline_path/pipeline_build_image_version.txt"
version=$(cat $version_path)
ecr_image_prefix="347157418948.dkr.ecr.us-east-2.amazonaws.com"
image_name="tradewinds/codebuildimage"
export AWS_PROFILE="hashhouseremoteadmin"

if command -v semver &> /dev/null
then
  version=$(semver bump minor $version)
  echo $version > $version_path
fi

docker_login_cmd=$(aws ecr get-login --region "us-east-2" --no-include-email)
eval $docker_login_cmd
docker build -t $image_name:$version -t $ecr_image_prefix/$image_name:$version -f $pipeline_path/Dockerfile .
docker push $ecr_image_prefix/$image_name:$version