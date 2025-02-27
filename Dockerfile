FROM crystallang/crystal:1.2.2-alpine AS builder
RUN apk update && apk upgrade && apk add sqlite-static
WORKDIR /build/
ARG version
RUN git clone --branch main --depth 1 https://github.com/dannypage/ktistec .
RUN shards install --production
RUN crystal build src/ktistec/server.cr --static --no-debug --release

FROM alpine:latest AS server
RUN apk --no-cache add tzdata
WORKDIR /app
COPY --from=builder /build/public /app/public
COPY --from=builder /build/server /bin/server
RUN mkdir /db
RUN ln -s /app/public/uploads /uploads
ENV KTISTEC_DB=/db/ktistec.db
CMD ["/bin/server"]
VOLUME /db /uploads
EXPOSE 3000
