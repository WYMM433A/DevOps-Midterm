# 1. Use Node.js 20 Alpine as the base image for a small footprint
FROM node:20-alpine

# 2. Set the working directory inside the container
WORKDIR /usr/src/app

# 3. Copy package.json to leverage Docker's caching mechanism
COPY package.json ./

# 4. Install only production dependencies
# This ignores 'nodemon' listed in your devDependencies
RUN npm install --omit=dev

# 5. Copy the rest of your application code
COPY . .

# 6. Expose the port your app runs on (Port 3000 as seen in your Nginx config)
EXPOSE 3000

# 7. Command to start the application
CMD ["npm", "start"]