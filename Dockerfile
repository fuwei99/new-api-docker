# Stage 0: Fetcher - Get latest code and replace file
# Use an image with git installed
FROM alpine/git:latest AS fetcher

# Define a build argument to bust the cache
# ARG CACHE_BUSTER -- Removed as it cannot be passed dynamically on HF

# Set working directory
WORKDIR /app

# Clone the main repository
# Add date command output to a file to bust cache *before* cloning
RUN date +%s > /tmp/build_timestamp.txt && \
    git clone --depth 1 https://github.com/QuantumNous/new-api.git .

# Copy the custom EditChannel.js from the local build context
COPY EditChannel.js ./web/src/pages/Channel/EditChannel.js
RUN echo "EditChannel.js copied from local context successfully."

# Stage 1: Frontend Builder - Build the web UI using bun
FROM oven/bun:latest AS frontend-builder

WORKDIR /build

# Copy package.json first to leverage Docker cache for dependencies
COPY --from=fetcher /app/web/package.json .
RUN bun install

# Copy the rest of the web source code and the VERSION file
COPY --from=fetcher /app/web .
COPY --from=fetcher /app/VERSION .

# Build the frontend, reading version from the VERSION file
RUN DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat VERSION) bun run build


# Stage 2: Backend Builder - Build the Go application
FROM golang:alpine AS backend-builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux

WORKDIR /build

# Copy Go module files first for dependency caching
COPY --from=fetcher /app/go.mod /app/go.sum ./
RUN go mod download

# Copy the entire application source code from the fetcher stage
COPY --from=fetcher /app .

# Copy the built frontend assets from the frontend-builder stage
COPY --from=frontend-builder /build/dist ./web/dist

# Build the Go application, embedding the version
RUN go build -ldflags "-s -w -X 'one-api/common.Version=$(cat VERSION)'" -o one-api


# Stage 3: Final Stage - Create the final runtime image
FROM alpine

# Update, upgrade, install runtime dependencies and clean up
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ca-certificates tzdata ffmpeg && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

# Copy the built Go application from the backend-builder stage
COPY --from=backend-builder /build/one-api /one-api

# Create the logs directory and ensure /data is writable by the application user
RUN mkdir -p /data/logs && \
    chmod -R a+w /data

# Expose the application port
EXPOSE 3000

# Set the working directory for the running container
WORKDIR /data

# Define the entry point for the container
ENTRYPOINT ["/one-api"] 