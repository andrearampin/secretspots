FROM golang:1.11
ENV GO111MODULE="on"

WORKDIR /go/src/app
COPY ./back .

RUN go get github.com/codegangsta/gin

EXPOSE 3000

CMD ["gin", "run", "main.go"]
