FROM node:16-alpine3.16 AS node

#############################################################################################
FROM node AS deps

ARG TZ='Europe/Istanbul'
ENV TZ ${TZ}
RUN apk upgrade --update \
    && apk add -U tzdata \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && apk del tzdata \
    && rm -rf \
    /var/cache/apk/*

#############################################################################################
FROM deps AS react

WORKDIR /app

COPY package*.json .
COPY yarn.lock /app

RUN yarn install

#############################################################################################
FROM react AS prod

WORKDIR /app

COPY . /app

VOLUME /app

EXPOSE 5173

ENV HOST=0.0.0.0
ENV PORT=5173

RUN export TZ=${TZ}

CMD ["yarn", "run", "dev"]

#############################################################################################
FROM prod
