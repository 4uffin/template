# This is a multi-stage Dockerfile for a Node.js application,
# designed for a consistent, isolated, and efficient production environment.

# Stage 1: The Build Environment
# Use a specific, stable Node.js LTS image for consistency
FROM node:18.17.1-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker's cache
# This ensures a faster build by only re-running npm install when dependencies change
COPY package*.json ./

# Install dependencies, clean the cache, and create a non-root user
RUN npm install && \
    npm cache clean --force && \
    adduser --disabled-password --home /app appuser

# Copy the rest of the application code
COPY . .

# Run the build command
RUN npm run build

# Stage 2: The Production Environment
# Use a lightweight Node.js image for a smaller final image size
FROM node:18.17.1-alpine

# Set the working directory
WORKDIR /app

# Copy only the necessary files from the builder stage
# This creates a lean image, reducing the attack surface and image size
COPY --from=builder --chown=appuser:appuser /app/build ./build
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appuser /app/package.json ./package.json

# Switch to the non-root user for security
USER appuser

# Define environment variables
ENV NODE_ENV=production

# Expose the port your app will run on
EXPOSE 3000

# Add a health check to ensure the container is running correctly
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl --fail http://localhost:3000 || exit 1

# Define the command to run your application
CMD ["npm", "start"]
