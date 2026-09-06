# Stage 1: Development/Build Stage
FROM node:20-alpine3.21 AS builder

# Set working directory
WORKDIR /app

# Install necessary build dependencies
RUN apk add --no-cache \
    python3=3.12.14-r0 \
    make=4.4.1-r2 \
    g++=14.2.0-r4


# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all project files
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Production Stage - Alpine with latest security patches and non-root user
FROM alpine:3.21 

# Install Node.js runtime with pinned versions to comply with DL3018
RUN apk add --no-cache \
    nodejs=22.23.2-r0 \
    npm=10.9.1-r0 \
    dumb-init=1.2.5-r3

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Copy necessary files from builder stage with proper ownership
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Switch to non-root user
USER nextjs

# Expose the port the app runs on
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Healthcheck to verify container is healthy
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Command to run the application
CMD ["node", "server.js"]
