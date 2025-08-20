# A Dockerfile contains instructions for building a Docker image. It's used to create a consistent and isolated environment for your application. This is a basic example for a Node.js application.

# Use a Node.js official image as the base
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
# This is done first to leverage Docker's caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Expose the port your app will run on
EXPOSE 3000

# Define the command to run your application when the container starts
CMD ["npm", "start"]
