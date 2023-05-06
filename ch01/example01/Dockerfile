FROM registry.access.redhat.com/ubi8/go-toolset@sha256:168ac23af41e6c5a6fc75490ea2ff9ffde59702c6ee15d8c005b3e3a3634fcc2 AS build

COPY ./hello/* .
RUN go mod init hello 
RUN go mod tidy
RUN go build .

FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:6a56010de933f172b195a1a575855d37b70a4968be8edb35157f6ca193969ad2
LABEL org.opencontainers.image.title "Hello from Path"
LABEL org.opencontainers.inage.description "Kubernetes Secret Management Handbook - Chapter 01 - Containter Build Example"

COPY --from=build ./opt/app-root/src/hello .

EXPOSE 8080
ENTRYPOINT ["./hello"]

