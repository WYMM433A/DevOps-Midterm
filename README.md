# DevOps-Midterm — Cloud Migration & Containerization

**Course:** 502094 - Software Deployment, Operations and Maintenance
**Institution:** Ton Duc Thang University (TDTU)

---

## Overview

This project deploys a Node.js/Express + MongoDB product management web application onto an AWS EC2 Ubuntu 22.04 server using two distinct approaches:

- **Phase 2:** Traditional host-based deployment using Nginx as a reverse proxy and PM2 as a process manager
- **Phase 3:** Modern containerized deployment using Docker and Docker Compose

The project demonstrates practical DevOps competencies including repository management, Linux automation, cloud provisioning, firewall configuration, reverse proxy setup, HTTPS provisioning, containerization, image registry usage, and deployment comparison.

A comparative analysis between both deployment models is documented in the technical report.

---

## Live Application

- **URL:** https://wymm.online
- **Docker Hub:** https://hub.docker.com/r/wymm433a/midterm-app

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
├── app/                          # Instructor sample Node.js project
│   ├── controllers/              # Request/response logic
│   ├── models/                   # Mongoose schema (Product)
│   ├── routes/                   # API and UI routes
│   ├── services/                 # Data abstraction layer (MongoDB / in-memory)
│   ├── validators/               # Input validation
│   ├── views/                    # EJS templates
│   ├── public/
│   │   ├── css/
│   │   ├── js/
│   │   └── uploads/              # Product images (gitignored)
│   ├── main.js                   # Application entry point
│   ├── package.json
│   └── .env.example              # Environment variable template
├── phase1/
│   ├── scripts/
│   │   └── setup.sh              # Server automation script
│   ├── screenshots/              # Branch protection, PRs, contributors
│   └── docs/                     # Architecture diagrams
├── phase2/
│   ├── nginx/
│   │   └── app.conf              # Nginx reverse proxy configuration
│   ├── screenshots/              # DNS, HTTPS, PM2 evidence
│   └── .env.example              # Environment variable template
├── phase3/
│   ├── Dockerfile                # Production Docker image definition
│   ├── docker-compose.yml        # Multi-container orchestration
│   ├── screenshots/              # Docker build, push, ps evidence
│   └── .env.example              # Environment variable template
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
- MongoDB running locally (or use MongoDB Atlas)

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

### Development Mode (with auto-reload)
```bash
npm run dev
```

---

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `PORT` | Application listening port | `3000` |
| `MONGO_URI` | MongoDB connection string | `mongodb://localhost:27017/products_db` |

Create a `.env` file in the `app/` directory:
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

Example — create a product with image upload:
```bash
curl -X POST \
  -F "name=My Device" \
  -F "price=199" \
  -F "color=black" \
  -F "description=Note" \
  -F "imageFile=@/path/to/photo.jpg" \
  http://localhost:3000/products
```

---

## Automation Script

`phase1/scripts/setup.sh` prepares a fresh Ubuntu 22.04 server by automatically:

1. Updating system packages
2. Installing Node.js 20 LTS
3. Installing MongoDB 7.0 and starting the service
4. Installing Git and PM2
5. Running `npm install` for the application
6. Creating a default `.env` file
7. Starting the application with PM2
8. Configuring PM2 to restart on server reboot
9. Installing and configuring Nginx as a reverse proxy
10. Installing a Let's Encrypt SSL certificate via Certbot

Run on your Ubuntu server:
```bash
# Clone the repo first
git clone https://github.com/WYMM433A/DevOps-Midterm.git

# Then run the script
bash DevOps-Midterm/phase1/scripts/setup.sh
```

> The script assumes the repo is cloned at `~/DevOps-Midterm` before execution.

---

## Deployment

### Phase 2 — Traditional Deployment
- AWS EC2 Ubuntu 22.04 (t2.micro)
- MongoDB running natively on the server
- Application managed by PM2
- Nginx reverse proxy on ports 80/443
- HTTPS via Let's Encrypt (Certbot)
- Domain: https://wymm.online

Full deployment is automated via `phase1/scripts/setup.sh`.

### Phase 3 — Docker Deployment
- Same EC2 server
- Application and MongoDB containerized via Docker Compose
- Nginx remains on host, upstream updated to container port
- Persistent volumes for uploads and database data
- Images pulled from Docker Hub

```bash
# Deploy Phase 3
cd phase3
docker compose pull
docker compose up -d
docker ps
```

---

## Git Workflow

This project follows a professional Git collaboration workflow:

- All development is done in **feature branches** (`feat/`, `fix/`)
- All merges to `main` are done via **Pull Requests**
- Every PR requires at least **1 approving review**
- **Branch protection** is enforced on `main` — no direct pushes allowed
- All team members contribute via meaningful commits

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
- Uploaded images are stored in `app/public/uploads/` — this directory is gitignored
- For production use, consider migrating image storage to AWS S3 or Cloudinary
- The `.env` file is never committed to the repository — use `.env.example` as a template
- Auto-renew on the domain has been disabled as per course instructions