# Stage 1: build
FROM node:18-bullseye AS builder
WORKDIR /app

# Install system deps (for Rust native builds)
RUN apt-get update && apt-get install -y \
    python3 make g++ curl git pkg-config libssl-dev \
    build-essential cargo \
    && rm -rf /var/lib/apt/lists/*

# Copy and install deps with Yarn 4
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN yarn install --immutable

# Copy source
COPY . .

# Build the project
RUN yarn build


# Stage 2: runtime
FROM node:18-bullseye AS runtime
WORKDIR /app

# Copy package manager files
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn

# Install only production dependencies for runtime
RUN yarn workspaces focus --all --production

# Copy built artifacts from builder
COPY --from=builder /app . 

# Use non-root user
RUN useradd -m affine
USER affine

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# Serve frontend build
CMD ["yarn", "serve", "-s", "dist", "-l", "3000"]
