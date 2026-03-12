FROM alpine

RUN apk add gcc make

WORKDIR /app

COPY ./src .

RUN make

CMD ["./mcp"]