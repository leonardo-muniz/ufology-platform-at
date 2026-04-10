#!/bin/bash
docker build -t leonardocmuniz/ufodb:1.0 docker/database
docker build -t leonardocmuniz/ufo-tracker:1.0 .