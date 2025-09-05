# Stage 1: build
FROM node:18-bullseye AS builder
WORKDIR /app

# Install system dependencies (for Rust/native builds)
RUN apt-get update && apt-get install -y \
    python3 make g++ curl git pkg-config libssl-dev \
    build-essential cargo \
    && rm -rf /var/lib/apt/lists/*

# Copy Yarn files
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn

# Copy all workspace packages (needed for Yarn workspaces)
COPY packages ./packages
COPY tools ./tools
COPY blocksuite ./blocksuite
COPY frontend ./frontend
COPY docs ./docs
COPY tests ./tests

# Install dependencies
RUN yarn install --immutable

# Copy the rest of the source code
COPY . .

# Build the project
RUN yarn build


# Stage 2: runtime
FROM node:18-bullseye AS runtime
WORKDIR /app

# Copy only required files from builder
COPY --from=builder /app/package.json /app/yarn.lock /app/.yarnrc.yml ./
COPY --from=builder /app/.yarn .yarn
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Use non-root user
RUN useradd -m affine
USER affine

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# Serve frontend build
CMD ["yarn", "serve", "-s", "dist", "-l", "3000"]
