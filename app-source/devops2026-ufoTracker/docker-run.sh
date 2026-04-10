#!/bin/bash
docker run -d --rm \
--name ufodb \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=Senha123 \
-e POSTGRES_DB=ufology \
-p 5432:5432 \
leonardocmuniz/ufodb:1.0

docker run -d --rm \
--name ufo-tracker \
leonardocmuniz/ufo-tracker:1.0