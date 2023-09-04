FROM node:16-alpine3.16 AS node

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

FROM deps AS react

WORKDIR /app

COPY . /app

ARG NODE_ENV='production'
ARG VITE_BASE_URL='http://localhost:3008'
RUN { \
  echo NODE_ENV=$NODE_ENV; \
  echo VITE_NODE_ENV=$NODE_ENV; \
  echo VITE_BASE_URL=$VITE_BASE_URL; \
} > .env
ENV PATH /app/node_modules/.bin:$PATH

RUN yarn install && \
    yarn run build

#############################################################################################
FROM nginx:alpine AS prod

RUN ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime && echo "Europe/Istanbul" > /etc/timezone
COPY --from=react /app/dist /usr/share/nginx/html
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d

#############################################################################################
FROM prod
