# Product API + UI (Express + MongoDB, fallback in-memory)

> **Note:** This project is provided as a reference foundation for students conducting their mid-term presentation in the course 502094 - Software Deployment, Operations And Maintenance (compiled by MSc. Mai Van Manh). Students are not required to use this exact project — you can choose or build an equivalent (or more complex) project, using a different language or framework if desired.

This is a sample project organized according to the MVC (Model — View — Controller) pattern, built with Node.js + Express, and uses MongoDB (Mongoose) to store product data. If the server cannot connect to MongoDB during startup (3s timeout), the application will automatically switch to an `in-memory` datastore and continue running.

**Key Features**

* Full REST API for Product management: CRUD (GET/POST/PUT/PATCH/DELETE).
* Server-side rendered UI using `EJS` combined with `Bootstrap` to manage products (interface at `/`).
* Each JSON response includes `hostname` and `source` information (whether data is being fetched from `mongodb` or `in-memory`).
* Supports image upload for products: images are saved to disk in `public/uploads/`, and the `imageUrl` field in the product stores the relative path (`/uploads/<filename>`).
* When updating or deleting a product, the old image file (located in `/uploads/`) will be deleted from the disk.
* On startup, if the MongoDB connection is successful and the collection is empty, the application will automatically seed 10 sample Apple products into MongoDB.

**Main Structure**

* `main.js` — entrypoint: connects to MongoDB (3s timeout), handles in-memory fallback, and starts Express.
* `models/product.js` — Mongoose schema (`name`, `price`, `color`, `description`, `imageUrl`).
* `services/dataSource.js` — abstract layer between MongoDB and in-memory (handles seeding, CRUD operations, and file deletion when necessary).
* `controllers/` — controllers to handle request/response logic.
* `routes/` — routes for the API (`/products`) and UI (`/`).
* `views/` — `EJS` templates for the UI.
* `public/` — static files: CSS, JS, and `uploads/` (where images are stored).

**Requirements & Configuration**

* Node.js 16+ (or compatible version) and `npm`.
* Environment file `.env` (a sample file is included in the repo):

```text
PORT=3000
MONGO_URI=mongodb://localhost:27017/products_db

```

If you want to connect to MongoDB with a username/password, adjust the `MONGO_URI` accordingly.

**Installation & Running Locally**

1. Install dependencies:

```bash
cd /Users/mvmanh/Desktop/api
npm install

```

2. Start the server:

```bash
# Run in production mode (node)
npm start

# Or run in development mode with nodemon
npm run dev

```

3. Open your browser and go to: `http://localhost:3000/` — the UI page will display the product list and provide Add / Edit / Delete actions.

**API (JSON) — Main Endpoints**

* `GET /products` — get the list of products.
* `GET /products/:id` — get details of a single product.
* `POST /products` — create a new product. Supports multipart form-data for image uploads (file field: `imageFile`) and text fields: `name`, `price`, `color`, `description`.
* `PUT /products/:id` — replace an entire product. Supports multipart file upload.
* `PATCH /products/:id` — partially update a product. Supports multipart file upload.
* `DELETE /products/:id` — delete a product and its corresponding image file if the image is stored in `/uploads/`.

Example of creating a product (using curl, with file upload):

```bash
curl -X POST -F "name=My Device" -F "price=199" -F "color=black" -F "description=Note" -F "imageFile=@/path/to/photo.jpg" http://localhost:3000/products

```

*Note:* The UI on the homepage uses `fetch` + `FormData` to send files, so you do not need to change anything if you are using the interface.

**Important Behavior**

* On startup, `main.js` attempts to connect to MongoDB with `serverSelectionTimeoutMS: 3000`. If it fails, the application will log the error and use `in-memory` storage for the duration of the process lifecycle.
* When MongoDB connects successfully and the `products` collection is empty, the repository will seed 10 sample Apple products (with `name`, `price`, `color`, `description`, and a default empty `imageUrl`).
* Images are saved on the disk at `public/uploads/` and are served statically by Express; the path saved in the DB is relative (`/uploads/<filename>`).
* When a new image is updated for a product, the old file (if it exists and is located in `/uploads/`) will be deleted.

**Limitations & Recommendations**

* Currently, the server allows uploading files and saving them directly to the disk — this is suitable for demos and dev environments, but not optimal for production (regarding backups, scaling, and bandwidth). For a production environment, you should use cloud storage (like S3/Cloudinary) and only store the URL in the DB.
* Add file size limits and check MIME types if you want it to be more secure. I can add `multer` configurations to limit the size (e.g., 2MB) and whitelist `image/*`.

**Utility Commands**

* Install `nodemon` globally (optional): `npm i -g nodemon`.
* Check server logs (stdout) to see whether the app is using `mongodb` or `in-memory`.

**How I can help further**

* Add file size limits and MIME type validation.
* Or migrate image storage to S3/Cloudinary (requires credentials).
* Add a product details page or pagination for the list.

If you want me to update the README to clearly state how to migrate data, how to reset uploads, or provide more specific examples, let me know your specific requirements and I will add them.