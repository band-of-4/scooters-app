#!/bin/bash

docker compose dovn -v
docker compose up -d
bin/rails db:migrate
bin/rails db:seed
bin/rails server
echo "START APPLICATON"