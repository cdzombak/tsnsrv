FROM golang:1.21 as builder

WORKDIR /work
ENV CGO_ENABLED=0

COPY go.mod go.sum ./
RUN go mod download && \
    go mod verify && \
    echo 'package main\nimport (\n_ "tailscale.com/tsnet"\n_ "tailscale.com/client/tailscale"\n)\nfunc main(){}' > main.go && \
    go build -ldflags="-s -w" -v ./ && \
    rm main.go

COPY . .

RUN go build -ldflags="-s -w" -v

FROM scratch
COPY --from=builder /work/tsnsrv /usr/bin/tsnsrv

CMD ["/usr/bin/tsnsrv"]
