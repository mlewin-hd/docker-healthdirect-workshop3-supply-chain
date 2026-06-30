# Workshop 3 — End-to-End Supply Chain Pipeline (template)

A ready-to-fork GitHub Actions pipeline that runs the **whole container supply chain in one place**:

```
build  ->  SBOM + signed provenance attestations  ->  Docker Scout scan  ->  push (pinned by digest)
```

Every stage is a concept from Workshop 3 — this template just makes it automatic and repeatable. It is built entirely on **Docker's official GitHub Actions**.

## What's in here

| File | Purpose |
|---|---|
| `.github/workflows/supply-chain.yml` | The pipeline — one job, one stage per step |
| `Dockerfile` | A minimal image (`python:3.13-slim` — the slim-base fix from Lab 3) |
| `app.py` | A trivial app so the image does something |

## How the stages map to the workshop

| Pipeline step | Supply-chain concept |
|---|---|
| Build, attest, and push (`sbom: true`, `provenance: mode=max`) | the image + **SBOM** (ingredients) + **signed provenance** (who/how it was built) |
| Scan with Docker Scout (`command: cves`) | **is it vulnerable?** — read by severity |
| Show the digest to pin | **has it changed?** — pin by `sha256` digest |
| `push: true` to Docker Hub | the **registry** as the trust boundary |

> **About "signing".** The `provenance: mode=max` attestation is a *signed* statement of how the image was built — that is the verifiable-origin guarantee in this template. A separate image **signature** (for example with cosign or Notation) is an optional extension beyond this Docker-first beginner template.

## Run it (hands-on)

You need a **GitHub account** and a **Docker Hub account**.

### 1. Fork this repository
Click **Fork** (top right) into your own GitHub account.

### 2. Enable Actions on your fork
Open the **Actions** tab and click **"I understand my workflows, go ahead and enable them"** — forks have Actions disabled by default.

### 3. Add your Docker Hub credentials
In your fork: **Settings → Secrets and variables → Actions**.

- **Variables** tab → **New repository variable**:
  - Name `DOCKERHUB_USERNAME` · Value: your Docker Hub username
- **Secrets** tab → **New repository secret**:
  - Name `DOCKERHUB_TOKEN` · Value: a Docker Hub **access token**

> **Make the token:** Docker Hub → your avatar → **Account settings → Personal access tokens → Generate new token**, with **Read & Write** access. Copy it once — it is shown only at creation. It is a credential: it goes in the **secret**, never in a file.

### 4. Run the workflow
**Actions** tab → **supply-chain** → **Run workflow** → **Run workflow**. (It also runs on every push to `main`.)

### 5. Watch and read it
Open the running job. Each step is a supply-chain stage:

- **Build, attest, and push** — the SBOM and provenance attestations are attached, and the image is pushed.
- **Scan with Docker Scout** — the Critical/High findings for your image.
- **Show the digest to pin** — copy the `sha256` digest; that is what you would pin in production.

On Docker Hub, open your `supply-demo` repository to see the pushed image.

## Make it a policy gate (optional)
In `supply-chain.yml`, add `exit-code: true` to the Scout step. Re-run: the pipeline now **fails** if Critical/High vulnerabilities are present — the same scan, now enforcing a rule.

## Local fallback (no GitHub needed)
The same stages run on your laptop — see Workshop 3b, Lab 4, "Run the chain locally":

```
docker buildx build --sbom=true --provenance=true -t supply-demo:pipeline .
docker scout cves supply-demo:pipeline
docker scout sbom supply-demo:pipeline
```

## Action versions
Pinned to the current majors shown in Docker's GitHub Actions documentation at authoring time:
`actions/checkout@v4`, `docker/setup-buildx-action@v4`, `docker/login-action@v4`, `docker/build-push-action@v7`, `docker/scout-action@v1`.
If a pin ever fails to resolve, check that action's GitHub Marketplace page for the current major and bump it.
