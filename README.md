# DevOps-Midterm — Cloud Migration & Containerization

**Course:** 502094 - Software Deployment, Operations and Maintenance  
**Institution:** Ton Duc Thang University (TDTU)

---

## Overview

This project deploys a Node.js/Express + MongoDB product management web application onto an AWS EC2 Ubuntu 22.04 server using two distinct approaches:

- **Phase 2:** Traditional host-based deployment using Nginx as a reverse proxy and PM2 as a process manager, accessible at **https://wymm.online**
- **Phase 3:** Modern containerized deployment using Docker and Docker Compose, accessible at **https://vestarex20.shop**

The project demonstrates practical DevOps competencies including repository management, Linux automation, cloud provisioning, firewall configuration, reverse proxy setup, HTTPS provisioning, containerization, image registry usage, and deployment comparison. A comparative analysis between both deployment models is documented in the technical report.

---

## Live Applications

| Phase | Type | URL |
|---|---|---|
| Phase 2 | Traditional (PM2 + MongoDB) | https://wymm.online |
| Phase 3 | Containerized (Docker + Compose) | https://vestarex20.shop |

---

## Docker Hub

- **Image:** https://hub.docker.com/r/akh2100/midterm-app

---

## Tech Stack

| Component | Technology |
|---|---|
| Backend | Node.js 20 + Express |
| Database | MongoDB 7.0 |
| View Engine | EJS + Bootstrap |
| Web Server | Nginx (reverse proxy) |
| Process Manager | PM2 (Phase 2) |
| Containerization | Docker + Docker Compose (Phase 3) |
| Container Registry | Docker Hub |
| Cloud Provider | AWS EC2 — Ubuntu 22.04 LTS |
| SSL Certificate | Let's Encrypt (Certbot) |
| Version Control | GitHub (branch protection + pull requests) |

---

## Repository Structure

```
DevOps-Midterm/
├── app/                              # Instructor sample Node.js project
│   ├── controllers/                  # Request/response logic
│   ├── models/                       # Mongoose schema (Product)
│   ├── routes/                       # API and UI routes
│   ├── services/                     # Data abstraction layer
│   ├── validators/                   # Input validation
│   ├── views/                        # EJS templates
│   ├── public/                       # Static files (CSS, JS, images)
│   ├── uploads/                      # Product image uploads (gitignored)
│   ├── Dockerfile                    # Production Docker image definition
│   ├── main.js                       # Application entry point
│   ├── package.json
│   └── .env.example                  # Environment variable template
├── phase1/
│   ├── scripts/
│   │   └── setup.sh                  # Phase 2 server automation script
│   ├── screenshots/                  # Git workflow evidence
│   └── docs/                         # Architecture diagrams
├── phase2/
│   ├── nginx/
│   │   └── app.conf                  # Nginx reverse proxy configuration
│   └── screenshots/                  # Deployment evidence
├── phase3/
│   ├── scripts/
│   │   └── docker-setup.sh           # Phase 3 Docker deployment script
│   ├── docker-compose.yml            # Multi-container orchestration
│   └── screenshots/                  # Docker deployment evidence
├── .gitignore
└── README.md
```

---

## Application Features

- Full REST API for Product management: CRUD (GET / POST / PUT / PATCH / DELETE)
- Server-side rendered UI using EJS + Bootstrap
- Image upload support — files saved to `public/uploads/`
- MongoDB connection with automatic fallback to in-memory storage
- Auto-seeds 10 sample Apple products on first startup with empty MongoDB collection
- Each response includes `hostname` and `source` fields for observability

---

## Run Locally

### Prerequisites
- Node.js 16+ and npm
- MongoDB running locally or MongoDB Atlas account

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/WYMM433A/DevOps-Midterm.git
cd DevOps-Midterm

# 2. Install dependencies
cd app
npm install

# 3. Configure environment
cp .env.example .env
# Edit .env with your MongoDB URI

# 4. Start the application
npm start

# 5. Open browser
# http://localhost:3000
```

### Development Mode
```bash
npm run dev
```

---

## Environment Variables

| Variable | Description | Example |
|---|---|---|
| `PORT` | Application listening port | `3000` |
| `MONGO_URI` | MongoDB connection string | `mongodb://localhost:27017/products_db` |

Create a `.env` file inside the `app/` directory:
```bash
PORT=3000
MONGO_URI=mongodb://localhost:27017/products_db
```

> ⚠️ Never commit the real `.env` file — it is excluded by `.gitignore`

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/products` | Get all products |
| GET | `/products/:id` | Get single product |
| POST | `/products` | Create product (supports image upload) |
| PUT | `/products/:id` | Replace entire product |
| PATCH | `/products/:id` | Partially update product |
| DELETE | `/products/:id` | Delete product and image |

---

## Phase 2 — Traditional Deployment

**Domain:** https://wymm.online  
**Script:** `phase1/scripts/setup.sh`

### What the Script Does
The automation script prepares a fresh Ubuntu 22.04 server in a single command:

1. Updates system packages
2. Installs Node.js 20 LTS
3. Adds and installs MongoDB 7.0
4. Installs PM2 process manager
5. Installs application dependencies
6. Creates `.env` file automatically
7. Starts application via PM2 with reboot persistence
8. Installs and configures Nginx reverse proxy
9. Provisions HTTPS certificate via Let's Encrypt

### How to Deploy

```bash
# Step 1 — SSH into EC2 server
ssh -i ~/your-key.pem ubuntu@YOUR_ELASTIC_IP

# Step 2 — Install Git (bootstrap prerequisite)
sudo apt-get update -y && sudo apt-get install -y git

# Step 3 — Clone repository
git clone https://github.com/WYMM433A/DevOps-Midterm.git

# Step 4 — Run automation script
bash DevOps-Midterm/phase1/scripts/setup.sh
```

### Architecture
```
Internet → Nginx (443/80) → PM2 Node.js App (3000) → MongoDB (27017)
```

---

## Phase 3 — Docker Deployment

**Domain:** https://vestarex20.shop  
**Script:** `phase3/scripts/docker-setup.sh`  
**Image:** `akh2100/midterm-app:v1`

### What the Script Does
The Docker deployment script automates the entire containerized setup:

1. Cleans up previous installations
2. Installs Docker and Docker Compose
3. Installs Nginx and Certbot
4. Pulls latest repository changes
5. Pulls Docker images from Docker Hub
6. Starts containers via Docker Compose
7. Configures Nginx reverse proxy
8. Provisions HTTPS certificate via Let's Encrypt

### How to Deploy

```bash
# Step 1 — SSH into EC2 server
ssh -i ~/your-key.pem ubuntu@YOUR_ELASTIC_IP

# Step 2 — Install Git (bootstrap prerequisite)
sudo apt-get update -y && sudo apt-get install -y git

# Step 3 — Clone repository
git clone https://github.com/WYMM433A/DevOps-Midterm.git

# Step 4 — Run Docker deployment script
bash DevOps-Midterm/phase3/scripts/docker-setup.sh
```

### Docker Compose Services

| Service | Image | Port | Purpose |
|---|---|---|---|
| `web` | `akh2100/midterm-app:v1` | 3000 | Node.js application |
| `database` | `mongo:7.0` | internal only | MongoDB database |

### Architecture
```
Internet → Nginx (443/80) → Docker web container (3000) → Docker MongoDB container
```

### Persistent Volumes

| Volume | Purpose |
|---|---|
| `mongo_data` | MongoDB database storage |
| `uploads_data` | Product image uploads |

---

## Git Workflow

This project follows a professional Git collaboration workflow:

- All development is done in **feature branches** (`feat/`, `fix/`)
- All merges to `main` are done via **Pull Requests**
- Every PR requires at least **1 approving review**
- **Branch protection** is enforced on `main` — no direct pushes allowed
- All team members contribute via meaningful commits

---

## Deployment Comparison

| Aspect | Phase 2 (Traditional) | Phase 3 (Docker) |
|---|---|---|
| App managed by | PM2 | Docker Compose |
| Database | Native MongoDB on host | MongoDB container |
| Portability | Host-dependent | Fully portable |
| Reproducibility | Manual steps required | Single script |
| Restart policy | PM2 + systemd | restart: always |
| Isolation | None | Full container isolation |
| Domain | https://wymm.online | https://vestarex20.shop |

---

## Team Members

| Name | GitHub |
|---|---|
| Wai Yan Moe Myint | [@WYMM433A](https://github.com/WYMM433A) |
| Aung Kaung Htet | [@Ko-Aung2100](https://github.com/Ko-Aung2100) |
| Saw Harry | [@MannDHHarry](https://github.com/MannDHHarry) |

---

## Important Notes

- The application includes a built-in fallback to in-memory storage if MongoDB is unavailable
- Uploaded images are stored in `app/uploads/` — this directory is gitignored
- The `.env` file is never committed — use `.env.example` as a template
- Git must be installed manually before cloning as a bootstrap prerequisite
- Auto-renew on both domains has been disabled as per course instructions
