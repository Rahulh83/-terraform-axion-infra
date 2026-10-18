# terraform-todoapp-infra

## Terraform GitHub Actions authentication

The dev workflow uses GitHub OIDC for both Terraform plan and apply. The Azure
app registration/service principal referenced by the `AZURE_CLIENT_ID` secret
must have a federated credential matching this GitHub repository, the `main`
branch for the plan job, and the `dev` GitHub Environment for the apply job.
The federated credential audience must be `api://AzureADTokenExchange`. The
`AZURE_TENANT_ID` and `AZURE_SUBSCRIPTION_ID` repository/environment secrets
must match that app registration and the intended subscription. The self-hosted
runner clock must be synchronized with UTC/NTP; OIDC assertions expire quickly,
so clock skew can cause AADSTS700024.

## Dummy React app: React + Docker + Helm + Argo CD

The app and Helm chart live under `terraform-todoapp-infra/` in this repository.
The React checklist and Nginx container are in
`terraform-todoapp-infra/apps/dummy-react`. The Helm chart is in
`terraform-todoapp-infra/gitops/helm/dummy-react`; the Argo CD `Application`
manifest is in `terraform-todoapp-infra/gitops/argocd/dummy-react-application.yaml`.

### 1. Set repository and image names

The repository currently has no Git remote, so replace `OWNER/REPOSITORY` in
both of these files with the GitHub owner and repository name (without `.git`):

- `terraform-todoapp-infra/gitops/argocd/dummy-react-application.yaml` (`repoURL`)
- `terraform-todoapp-infra/gitops/helm/dummy-react/values.yaml` (`image.repository`)

Set the image repository to `ghcr.io/OWNER/REPOSITORY/dummy-react`, matching
the GitHub Container Registry path produced by the included workflow.

### 2. Build and publish the container

Push the repository to GitHub on the `main` branch. The workflow
`.github/workflows/dummy-react-image.yaml` builds the React app and publishes
both `latest` and the source commit SHA tags to GHCR. It uses the repository's
built-in `GITHUB_TOKEN`; ensure GitHub Actions
has permission to write packages. In repository **Settings → Actions → General
→ Workflow permissions**, enable read and write permissions.

For a cluster without GHCR credentials, open the published package's settings
on GitHub and change its visibility to **Public** before deploying. For a
private package, configure an image pull secret and add its name to
`imagePullSecrets` in the Helm values instead.

### 3. Install with Argo CD

Ensure Argo CD is installed in the target cluster and can access the Git
repository. Apply the Application manifest:

```powershell
kubectl apply -f terraform-todoapp-infra/gitops/argocd/dummy-react-application.yaml
```

Argo CD creates the `dummy-react` namespace, installs the Helm chart, and keeps
the app synchronized with the `main` branch. The chart defaults to the `latest`
image tag. After each image publish, refresh/sync the Argo CD Application (or
enable Argo CD image updater to automate tag changes) to deploy a new image.
Check the rollout and open the app locally with:

```powershell
kubectl -n dummy-react get pods,svc
kubectl -n dummy-react port-forward svc/dummy-react 8080:80
```

Then browse to `http://localhost:8080`. The chart uses a ClusterIP Service by
default; enable and configure `ingress` in the values file if an ingress
controller is available.

### Local development and checks

Use Node.js 20 or newer. From the Git repository root, start Vite with:

```powershell
cd terraform-todoapp-infra/apps/dummy-react
npm install
npm run dev
```

Render the chart locally from the Git repository root with:

```powershell
helm lint terraform-todoapp-infra/gitops/helm/dummy-react
helm template dummy-react terraform-todoapp-infra/gitops/helm/dummy-react
```