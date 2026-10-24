# Hochschule Burgenland - Cluster Applications

[![Build status](https://img.shields.io/github/actions/workflow/status/muhlba91/hochschule-burgenland-cluster-applications/pipeline.yml?style=for-the-badge)](https://github.com/muhlba91/hochschule-burgenland-cluster-applications/actions/workflows/pipeline.yml)
[![License](https://img.shields.io/github/license/muhlba91/hochschule-burgenland-cluster-applications?style=for-the-badge)](LICENSE.md)
[![Scorecard](https://api.scorecard.dev/projects/github.com/muhlba91/hochschule-burgenland-cluster-applications/badge?style=for-the-badge)](https://scorecard.dev/viewer/?uri=github.com/muhlba91/hochschule-burgenland-cluster-applications)

This repository manages cloud-native applications and infrastructure for Hochschule Burgenland courses using [Argo CD](https://argo-cd.readthedocs.io/en/stable/) and [GitOps](https://opengitops.dev) principles.

## Architecture

The project implements the **App-of-Apps** pattern to provide automated bootstrapping and multi-tenant environment management.

- **Root Application:** Points to [`app-of-apps/`](app-of-apps/) to initialize the cluster-wide configuration.
- **Tenant Infrastructure:** Uses `ApplicationSet` in [`app-of-apps/bswe/groups.yaml`](app-of-apps/bswe/groups.yaml) to dynamically provision isolated environments for student groups.
- **Virtual Clusters:** Manages virtual Kubernetes instances via [`app-of-apps/vcluster/`](app-of-apps/vcluster/) for advanced isolation and testing.
- **Agents:** Manages cluster-side access for automated agents via [`app-of-apps/agents/`](app-of-apps/agents/), which deploys the manifests in [`agents/`](agents/).

### Core Components

The following Helm charts are located in [`charts/`](charts/):

- [`bswe-group`](charts/bswe-group/): Provisions tenant-specific infrastructure including `ResourceQuota`, `LimitRange`, `AppProject`, and Argo CD `Application` resources.
- [`cluster-access`](charts/cluster-access/): Provides access to virtual clusters by serving encrypted `kubeconfig` files via an Nginx service.
- [`vcluster`](charts/vcluster/): Deploys [vcluster](https://www.vcluster.com/) instances for virtualized Kubernetes environments.
- [`demo-app`](charts/demo-app/): A standard Nginx-based demonstration application for testing deployments.
- [`docusaurus`](charts/docusaurus/): Deployment for Docusaurus-based documentation sites.

### Agents

Manifests in [`agents/`](agents/) are deployed through the `hsb-grader` Argo CD `Application` ([`app-of-apps/agents/grader.yaml`](app-of-apps/agents/grader.yaml)):

- [`hsb-grader`](agents/hsb-grader/): Provides a read-only grader account for the course cluster. [`rbac.yaml`](agents/hsb-grader/rbac.yaml) creates the `hsb-grader` namespace, a `ServiceAccount` with a long-lived token `Secret`, and a `ClusterRole`/`ClusterRoleBinding` granting `get`/`list` on pods (incl. logs), services, events, deployments, replicasets, ingresses, Gateway API `HTTPRoute`s/`ListenerSet`s and Argo CD `Application`s in all namespaces. No `Secret` access and no write verbs are granted.

## Operations

### Bootstrapping

To bootstrap the cluster, configure your Argo CD instance to track the [`app-of-apps/`](app-of-apps/) directory.

### Virtual Cluster Management

Automated scripts in [`vclusters/`](vclusters/) assist with the lifecycle of virtual clusters:

- `playbook.sh`: Automates the retrieval of `kubeconfig` files and synchronizes them with the `cluster-access` service.
- `destroy.sh`: Cleans up local configuration and temporary files.

## Automation

- **CI/CD:** GitHub Actions validates YAML manifests and Helm chart integrity.
- **Dependency Management:** [Renovate Bot](https://github.com/renovatebot/renovate) maintains up-to-date container images and GitHub Actions versions.
