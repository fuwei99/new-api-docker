# Stage 0: Fetcher - Get latest code and replace file
FROM alpine/git:latest AS fetcher
WORKDIR /app
RUN git clone --depth 1 https://github.com/QuantumNous/new-api.git .

# [CRITICAL] Copy your modified file to the NEW location
# Replace 'EditChannelModal.jsx' with your local filename if different
COPY EditChannelModal.jsx ./web/src/components/table/channels/modals/EditChannelModal.jsx

# Stage 1: Frontend Builder
FROM oven/bun:latest AS frontend-builder
WORKDIR /build
COPY --from=fetcher /app/web/package.json .
COPY --from=fetcher /app/web/bun.lock . 
RUN bun install
COPY --from=fetcher /app/web .
COPY --from=fetcher /app/VERSION .
RUN DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat VERSION) bun run build

# Stage 2: Backend Builder
FROM golang:alpine AS backend-builder
ENV GO111MODULE=on CGO_ENABLED=0 GOOS=linux
ENV GOEXPERIMENT=greenteagc
WORKDIR /build
COPY --from=fetcher /app/go.mod /app/go.sum ./
RUN go mod download
COPY --from=fetcher /app .
COPY --from=frontend-builder /build/dist ./web/dist
RUN go build -ldflags "-s -w -X 'github.com/QuantumNous/new-api/common.Version=$(cat VERSION)'" -o new-api

# Stage 3: Final Runtime
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata libasan8 wget \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

COPY --from=backend-builder /build/new-api /
EXPOSE 3000
WORKDIR /data
ENTRYPOINT ["/new-api"]
