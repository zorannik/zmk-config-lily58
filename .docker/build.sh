#! /usr/bin/env bash

docker compose -p zmk down
yes | docker volume prune
docker compose -p zmk up
