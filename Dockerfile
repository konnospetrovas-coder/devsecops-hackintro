FROM alpine

RUN apk add gcc make linux-headers

WORKDIR /app

COPY ./src .

RUN make

CMD ["./mcp"]