# Hochschule Burgenland - Cluster Applications

[![Build status](https://img.shields.io/github/actions/workflow/status/muhlba91/hochschule-burgenland-cluster-applications/pipeline.yml?style=for-the-badge)](https://github.com/muhlba91/hochschule-burgenland-cluster-applications/actions/workflows/pipeline.yml)
[![License](https://img.shields.io/github/license/muhlba91/hochschule-burgenland-cluster-applications?style=for-the-badge)](LICENSE.md)
[![Scorecard](https://api.scorecard.dev/projects/github.com/muhlba91/hochschule-burgenland-cluster-applications/badge?style=for-the-badge)](https://scorecard.dev/viewer/?uri=github.com/muhlba91/hochschule-burgenland-cluster-applications)

This repository manages demo applications for Hochschule Burgenland courses using [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) and [GitOps](https://opengitops.dev) principles.

## Architecture

The project follows the **App-of-Apps** pattern for automated bootstrapping and management.

- **Root Application:** Points to [`app-of-apps/`](app-of-apps/) to initialize the cluster.
- **Group Infrastructure:** Uses `ApplicationSet` in [`app-of-apps/bswe/groups.yaml`](app-of-apps/bswe/groups.yaml) to dynamically provision environments for student groups.

### Core Components

The following Helm charts are located in [`charts/`](charts/):

- [`bswe-group`](charts/bswe-group/): Provisions group-specific infrastructure including `ResourceQuota`, `LimitRange`, `AppProject`, and ArgoCD `Application` resources.
- [`cluster-access`](charts/cluster-access/): Serves encrypted `kubeconfig` files via an Nginx service and PVC for vcluster access.
- [`vcluster`](charts/vcluster/): Deploys virtual Kubernetes clusters.
- [`demo-app`](charts/demo-app/): A simple Nginx-based demonstration application.
- [`docusaurus`](charts/docusaurus/): Documentation site deployment.

## Operations

### Bootstrapping

To bootstrap the cluster, point your ArgoCD instance to the [`app-of-apps/`](app-of-apps/) directory of this repository.

### vcluster Management

Helper scripts in [`vclusters/`](vclusters/) facilitate virtual cluster lifecycle management:

- `playbook.sh`: Retrieves Kubeconfigs and synchronizes them with the `cluster-access` service.
- `destroy.sh`: Removes stored configuration files.

## Automation

- **CI/CD:** GitHub Actions for YAML linting and validation.
- **Dependency Management:** [Renovate Bot](https://github.com/renovatebot/renovate) automates updates for container images and GitHub Actions.
