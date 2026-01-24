#!/bin/bash

docker compose down -v
docker compose up -d
until pg_isready -h 127.0.0.1 -p 5433; do
    echo "Ожидание PostgreSQL..."
    sleep 2
done
bin/rails db:migrate
bin/rails db:seed
bin/rails server
echo "START APPLICATON"