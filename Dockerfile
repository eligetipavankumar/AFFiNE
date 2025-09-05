# ---- Stage 1: Build ----
FROM node:18-bullseye AS builder

# Set working directory
WORKDIR /app

# Copy only package files to install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy rest of the project
COPY . .

# ---- Stage 2: Run ----
FROM node:18-bullseye-slim

# Set working directory
WORKDIR /app

# Copy only production dependencies from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app . 

# Expose port (replace with your app's port if different)
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]   # Replace server.js with your app's entry file
