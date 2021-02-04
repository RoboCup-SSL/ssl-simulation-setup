FROM golang:1.14-alpine AS build
WORKDIR /go/src/github.com/RoboCup-SSL/ssl-simulation-setup
COPY cmd cmd
COPY pkg pkg
RUN go install ./...

# Start fresh from a smaller image
FROM alpine:3.9
COPY --from=build /go/bin/ssl-simulation-proxy /app/ssl-simulation-proxy
ENTRYPOINT ["/app/ssl-simulation-proxy"]
CMD []
