# Stage 1: Build
FROM node:18-bullseye AS builder

WORKDIR /app

# Copy only package files first for faster caching
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install --frozen-lockfile

# Copy source code
COPY . .

# Build project
RUN npm run build

# Stage 2: Run
FROM node:18-bullseye-slim

WORKDIR /app

# Copy built artifacts and node_modules from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Set environment variables if needed
ENV NODE_ENV=production

# Start app
CMD ["node", "dist/index.js"]
