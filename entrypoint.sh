#!/bin/sh

set -e

echo "$INPUT_SERVICE_KEY" | base64 --decode > "$HOME"/gcloud.json

if [ "$INPUT_ENV" ]
then
    ENVS=$(cat "$INPUT_ENV" | xargs | sed 's/ /,/g')
fi

if [ "$ENVS" ]
then
    ENV_FLAG="--set-env-vars $ENVS"
else
    ENV_FLAG="--clear-env-vars"
fi

gcloud auth activate-service-account --key-file="$HOME"/gcloud.json --project "$INPUT_PROJECT"
gcloud auth configure-docker

if [ "$PUSH" ]
then
    docker push "$INPUT_IMAGE"
fi

gcloud beta run deploy "$INPUT_SERVICE" \
  --image "$INPUT_IMAGE" \
  --region "$INPUT_REGION" \
  --platform managed \
  --allow-unauthenticated \
  ${ENV_FLAG}
