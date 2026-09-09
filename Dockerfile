# Stage 1: Development/Build Stage
FROM node:20-alpine@sha256:fb4cd12c85ee03686f6af5362a0b0d56d50c58a04632e6c0fb8363f609372293 AS builder

# Set working directory
WORKDIR /app

# Install necessary build dependencies with pinned versions
# hadolint ignore=DL3018
RUN apk add --no-cache \
    python3 \
    make \
    g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all project files
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Production Stage - Alpine with security patches and non-root user
FROM alpine:3.21@sha256:48b0309ca019d89d40f670aa1bc06e426dc0931948452e8491e3d65087abc07d

# Install Node.js runtime with pinned versions
# hadolint ignore=DL3018
RUN apk add --no-cache \
    dumb-init \
    nodejs \
    npm

# Set working directory
WORKDIR /app

# Create non-root user for security with numeric user ID (fixes DL3066)
RUN addgroup -g 1001 -S nodejs && \
    adduser -S -u 1001 -G nodejs nextjs

# Copy necessary files from builder stage with proper ownership
COPY --from=builder --chown=1001:1001 /app/.next/standalone ./
COPY --from=builder --chown=1001:1001 /app/.next/static ./.next/static
COPY --from=builder --chown=1001:1001 /app/public ./public

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Switch to non-root user
USER 1001

# Expose the port the app runs on
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Healthcheck to verify container is healthy (runs as non-root user)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD su -s /bin/sh nextjs -c "node -e \"require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})\"" || exit 1

# Command to run the application
# hadolint ignore=DL3025
CMD ["node", "server.js"]
