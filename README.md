# Ufology Investigation Unit Platform

### [Acesse o relatório](./RELATORIO.md)

## Overview
This repository contains the infrastructure and application configuration for the official database and platform of the Ufology Investigation Unit. It encompasses Kubernetes manifests for deploying the application and its dependencies, alongside GitHub Actions workflows for continuous integration and continuous deployment.

## Architecture & Technologies
The platform is designed to be resilient and isolated, running entirely within a Kubernetes cluster.

* **Application:** A containerized Java application.
* **Database:** PostgreSQL database, managed via Hibernate ORM within the application.
* **Cache:** A Redis instance running on a lightweight Alpine Linux image to reduce database overhead from repeated sighting queries.
* **Orchestration:** Kubernetes. All resources are strictly isolated within a dedicated `ufology` namespace to prevent interference with other cluster systems.

## Kubernetes Resources
The `k8s/` directory contains all the necessary declarative manifests to spin up the environment:

* **Deployments:** Manages the Pod replicas for both the core application and the Redis cache.
* **Services:** Exposes the application and Redis using their standard ports, allowing internal cluster communication between components.
* **ConfigMap (`app-config`):** Injects the `POSTGRES_DB` configuration into the application dynamically.
* **Secret (`db-secret`):** Securely injects the `POSTGRES_PASSWORD` into the application, ensuring sensitive data is not exposed directly in the deployment manifests.

## CI/CD Pipelines (GitHub Actions)
The project utilizes GitHub Actions to automate testing, building, and deployment validations. The workflows are located in the `.github/workflows/` directory:

* **Hello Workflow (`hello.yml`):** A basic validation pipeline that triggers on any push event.
* **Test Pipeline (`tests.yml`):** Automatically triggers on pull requests to ensure new code passes automated tests before being merged.
* **Build Pipeline (`maven-ci.yml`):** Triggers on pushes to the `main` branch to build and package the project artifacts. 
* **Environment Variables Demo (`env-demo.yml`):** Demonstrates the usage and injection of environment variables during a pipeline run.
* **Secret Validation (`secret-demo.yml`):** Securely validates access to repository secrets without exposing their values in the execution logs.

## Getting Started
1. Ensure you have a running Kubernetes cluster and `kubectl` configured.
2. Apply the namespace first: `kubectl apply -f k8s/00-namespace.yaml`
3. Apply the ConfigMap and Secret.
4. Apply the Deployments and Services for the application and Redis.
