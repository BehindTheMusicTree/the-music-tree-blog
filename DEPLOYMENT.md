# Deployment (GCP Compute Engine — Always Free)

Guide for running this project's Docker Compose stack (SPIP + MariaDB) on a Google Compute Engine `e2-micro` VM, within the **Always Free** tier — no time limit, no cost, as long as usage stays within the quotas below.

> Always Free quota for Compute Engine:
>
> - **1x `e2-micro` instance/month**, non-preemptible, in one of: `us-west1` (Oregon), `us-central1` (Iowa), `us-east1` (South Carolina)
> - **30 GB-months** standard persistent disk
> - **1 GB/month** network egress from North America (excludes China, Australia)
>
> Staying inside these limits keeps the instance free indefinitely — no credits, no trial expiry.

## Table of contents

- [Deployment (GCP Compute Engine — Always Free)](#deployment-gcp-compute-engine--always-free)
  - [Table of contents](#table-of-contents)
  - [1. Prerequisites](#1-prerequisites)
  - [2. Create a dedicated project](#2-create-a-dedicated-project)
  - [3. Create the VM instance](#3-create-the-vm-instance)
  - [4. Open the app port](#4-open-the-app-port)
  - [5. Connect and install Docker](#5-connect-and-install-docker)
  - [6. Deploy the stack](#6-deploy-the-stack)
  - [7. Finish setup](#7-finish-setup)
    - [Fix SPIP directory permissions](#fix-spip-directory-permissions)
    - [Complete the SPIP installation](#complete-the-spip-installation)
      - [Database connection](#database-connection)
    - [Troubleshooting](#troubleshooting)
    - [`.htaccess` warning](#htaccess-warning)
  - [8. Staying within Always Free](#8-staying-within-always-free)
  - [Sources](#sources)

## 1. Prerequisites

- A Google Cloud account with billing enabled (required to create a project, even though usage stays free)
- An SSH client, or use the browser-based SSH built into the console

## 2. Create a dedicated project

Use a project dedicated to this stack rather than the default "My First Project":

- **Clean teardown**: deleting the project deletes every resource inside it (VM, disk, firewall rules) in one action.
- **Clear cost tracking**: Billing reports break down by project, so this stack's spend (should be $0) is easy to isolate.
- **Scoped IAM**: permissions and enabled APIs stay isolated to this app.

In the Cloud Console: **project selector (top-left) → New Project**, name it `the-music-tree-blog`, set **Organization** to `TheMusicTree`, and select your billing account.

**If the `TheMusicTree` organization doesn't exist yet**, a GCP organization resource is provisioned automatically from a verified **Cloud Identity** or Google Workspace account tied to a domain you own (`themusictree.org`) — there's no standalone "create org" button.

1. Sign up for [Cloud Identity Free](https://workspace.google.com/gcpidentity/signup) using an admin address on the domain (e.g. `admin@themusictree.org`).
2. Verify domain ownership: in the Admin console, **Verify domain**, then add the given TXT record (host `@`, value `google-site-verification=...`) to the domain's DNS. Verification can take minutes to a few hours; DNS propagation up to 72h.
3. Once verified, sign in to the Cloud Console with that account and create a project — the `TheMusicTree` organization resource is auto-created as the root of the resource hierarchy at that point.

After that, the organization exists permanently and every future project can be created under it directly. Manage it (view org structure, add projects/members) at [console.cloud.google.com/cloud-resource-manager](https://console.cloud.google.com/cloud-resource-manager).

**If signup says "This domain name is already in use"**: a Cloud Identity/Workspace org for `themusictree.org` already exists (likely from earlier ecosystem setup) — don't create a second one. Recover access instead:

1. Try [accounts.google.com/signin/recovery](https://accounts.google.com/signin/recovery) with the likely admin address (e.g. `admin@themusictree.org`).
2. If unknown, use [toolbox.googleapps.com/apps/recovery/domain_in_use](https://toolbox.googleapps.com/apps/recovery/domain_in_use) — enter the domain and it identifies which account owns it and the correct recovery path.
3. Sign in with that account and create the `the-music-tree-blog` project directly under the existing org — skip the signup/verification steps above.

Don't request Google release the domain without checking its history first — if the existing org has real data (Gmail, Drive, users), forcing a release can delete it.

> The Always Free `e2-micro` quota is **per billing account, shared across all projects** — not per project. A dedicated project does not grant an additional free VM; keep at most one `e2-micro` running across all projects under the same billing account, or the extra one gets billed.

## 3. Create the VM instance

In the Cloud Console, go to **Compute Engine → VM instances**. On a new project the Compute Engine API isn't enabled yet — click **Enable** (takes ~30–60s), then **Create instance**.

The creation page is split into left-nav sections — fill in:

| Section                   | Field        | Value                                                                                                                                                                                                 |
| ------------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Machine configuration** | Machine type | `e2-micro`                                                                                                                                                                                            |
|                           | Region       | `us-central1` (Iowa)                                                                                                                                                                                  |
|                           | Zone         | `us-central1-a`                                                                                                                                                                                       |
| **OS and storage**        | Name         | `the-music-tree-blog`                                                                                                                                                                                 |
|                           | Image        | `Debian GNU/Linux 13 (trixie)` (default)                                                                                                                                                              |
|                           | Type         | **New standard persistent disk** — click and change it, the default is "New balanced persistent disk", which is **not** covered by Always Free                                                        |
|                           | Size         | `30` GB — the default is 10 GB, but Standard persistent disk is free up to 30 GB regardless of usage, so raise it for headroom (Docker images, MariaDB growth, SPIP uploads) at no extra cost         |
| **Networking**            | Firewall     | check **Allow HTTP traffic** and **Allow HTTPS traffic**; leave **Allow load balancer health checks** unchecked — that rule is only needed behind a Cloud Load Balancer, which this setup doesn't use |

Leave **Data protection**, **Observability**, **Security**, and **Advanced** (provisioning model: **Standard**, on host maintenance: **Migrate VM instance**, automatic restart: **On**) at their defaults.

The **Monthly estimate** panel will show ~$6.11 for compute — that's expected, it always shows on-demand list price and doesn't account for the Always Free credit, which is applied automatically on your actual bill instead. The disk line should read $0.00 once set to Standard.

Click **Create**.

## 4. Open the app port

SPIP is served on container port `80`, mapped to host port `8080` per `docker-compose.yml`. Add a firewall rule for it:

1. **VPC network → Firewall → Create firewall rule**
2. Name: `allow-8080`, Targets: `All instances in the network`, Source IPv4 ranges: `0.0.0.0/0`, Protocols and ports: `tcp:8080`
3. **Create**

## 5. Connect and install Docker

```bash
gcloud compute ssh the-music-tree-blog --zone us-central1-a
```

(or use the **SSH** button next to the instance in the console)

> This same command reconnects to the VM any time later — no need to re-run install steps, just SSH back in from your dev terminal whenever you need to check logs, run `docker compose` commands, or debug something. Requires the [gcloud CLI](https://cloud.google.com/sdk/docs/install) authenticated (`gcloud auth login`) and the right project set (`gcloud config set project <PROJECT_ID>`).

On the instance:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg git

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker $USER
newgrp docker
```

## 6. Deploy the stack

```bash
git clone https://github.com/BehindTheMusicTree/the-music-tree-blog.git
cd the-music-tree-blog
./scripts/setup.sh
```

`setup.sh` clones SPIP core into `web/` and installs its Composer dependencies (via a throwaway `composer:2` container, since the VM has no PHP/Composer of its own).

Generate a strong random value for each password (run it twice — once for each):

```bash
openssl rand -base64 24
```

Edit `.env` (`nano .env`) and replace the defaults:

```
DB_ROOT_PASSWORD=<paste generated value>
DB_NAME=spip
DB_USER=spip
DB_PASSWORD=<paste a different generated value>
```

```bash
docker compose up -d
```

## 7. Finish setup

Find the instance's external IP:

- **Console**: **Compute Engine → VM instances** — the **External IP** column
- **CLI**:
  ```bash
  gcloud compute instances describe the-music-tree-blog \
    --zone us-central1-a \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
  ```

This IP is **ephemeral** by default — it can change if the instance is stopped or restarted. If you plan to point a domain at it (for HTTPS later, for example), reserve it as a **static IP** (**VPC network → IP addresses → Reserve external static address**).

> **Note:** A reserved static IP is billed while it is **not attached** to a running VM, so only reserve one if you intend to keep using it.

### Fix SPIP directory permissions

Before running the installer, make sure SPIP can write its configuration files.

From the project root, run:

```bash
docker compose exec spip chown -R www-data:www-data /var/www/html/config
```

If your service name differs from `spip`, replace it accordingly.

### Complete the SPIP installation

Open:

```
http://<INSTANCE_EXTERNAL_IP>:8080/ecrire/
```

Follow the installation wizard:

1. **Language**
   - Select **Français**.

2. **Database connection**
   - Enter the database credentials from your `.env` file.
   - Typical values are:
     - **Server:** `db` (the Docker Compose service name, **not** `localhost`)
     - **Username:** `spip`
     - **Password:** value from `.env`
     - **Database:** `spip`

3. **Database initialization**
   - SPIP will create the required tables automatically.

4. **Administrator account**
   - Create your administrator username and password.

Once the installation is complete, your website will be available at:

```
http://<INSTANCE_EXTERNAL_IP>:8080/
```

#### Database connection

When prompted for the database connection, use the values from your `.env` file.

| SPIP field                  | Value                |
| --------------------------- | -------------------- |
| **Database server address** | `db`                 |
| **Database login**          | `spip`               |
| **Database password**       | Password from `.env` |
| **Database name**           | `spip`               |

> **Important:** When using Docker Compose, the database server is **`db`**, **not** `localhost`. Docker services communicate using their service names.

After entering these values, click **Suivant** ("Next"). SPIP will verify the connection before creating the database tables.

### Troubleshooting

If SPIP reports that it cannot connect to the database, verify that the database container is running:

```bash
docker compose ps
```

Then inspect its logs:

```bash
docker compose logs db
```

If the installer reports that the `config/` directory is not writable, ensure the permissions were updated successfully and rerun:

```bash
docker compose exec spip chown -R www-data:www-data /var/www/html/config
```

### `.htaccess` warning

If SPIP displays the following warning:

> `.htaccess` is ignored by the web server.

Apache is not allowing `.htaccess` files to override its configuration.

With the official `spip/apache` image, don't edit Apache config inside a running container. Keep a project-owned vhost file and mount it through Docker Compose.

Create `docker/apache/spip.conf`:

```apache
<VirtualHost *:80>
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

Then mount it in `docker-compose.yml` on the `spip` service:

```yaml
services:
  spip:
    image: spip/apache:8.5
    ports:
      - "8080:80"
    volumes:
      - ./web:/var/www/html
      - ./squelettes:/var/www/html/squelettes
      - ./docker/apache/spip.conf:/etc/apache2/sites-available/000-default.conf:ro
```

Ensure the mounted vhost contains:

```apache
<Directory /var/www/html>
    AllowOverride All
    Require all granted
</Directory>
```

Also make sure the Apache `rewrite` module is enabled:

```bash
docker compose exec spip a2enmod rewrite
docker compose restart spip
```

Verify the active virtual host configuration:

```bash
docker compose exec spip apache2ctl -S
docker compose exec spip cat /etc/apache2/sites-available/000-default.conf
```

If you see:

```apache
<Directory /var/www/html>
  AllowOverride None
</Directory>
```

change it to:

```apache
<Directory /var/www/html>
  AllowOverride All
</Directory>
```

After restarting Apache, reload the SPIP administration page. The warning should disappear.

## 8. Staying within Always Free

- Keep exactly one `e2-micro` instance, in one of the three eligible regions.
- Keep the boot disk on Standard persistent disk, ≤30 GB.
- Watch egress if traffic grows — the 1 GB/month North America allowance is easy to exceed under real usage; check **Billing → Reports** to confirm actual spend stays at $0.

## Sources

- [Free Trial and Free Tier Services and Products | Google Cloud](https://cloud.google.com/free)
- [Compute Engine: Getting started with Always Free usage limits](https://cloud.google.com/free/docs/compute-getting-started)
