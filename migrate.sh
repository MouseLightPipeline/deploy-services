#!/usr/bin/env bash

if [[ -f "options.sh" ]]; then
    source "options.sh"
fi

if [[ -z "PIPELINE_COMPOSE_PROJECT" ]]; then
    export PIPELINE_COMPOSE_PROJECT="pipeline"
fi

docker run -it --rm --network ${PIPELINE_COMPOSE_PROJECT}_back_tier --env-file .env mouselightpipeline/pipeline-api:1.5 ./migrate.sh
