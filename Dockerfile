# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS builder
WORKDIR /src

COPY go.mod ./
COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/a2o main.go

FROM alpine:3.20
WORKDIR /app

RUN apk add --no-cache ca-certificates && \
    adduser -D -H -u 10001 appuser

COPY --from=builder /out/a2o /app/a2o
COPY docker/entrypoint.sh /app/entrypoint.sh
RUN chown -R appuser:appuser /app && chmod +x /app/entrypoint.sh

EXPOSE 11001

USER appuser
ENTRYPOINT ["/app/entrypoint.sh"]
