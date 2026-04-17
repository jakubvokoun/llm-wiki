# Node.js Docker Cheat Sheet

The following cheatsheet provides production-grade guidelines for building optimized and secure Node.js Docker images.

## 1) Use explicit and deterministic Docker base image tags

Docker images are always referenced by tags, and when you don't specify a tag the default `:latest` tag is used.

Shortcomings of building based on the default `node` image:
1. Docker image builds are inconsistent — every build will pull a newly built Docker image of `node`.
2. The node Docker image is based on a full-fledged operating system full of libraries and tools you may not need. The `node` image includes hundreds of security vulnerabilities of different types and severities.

Recommendations:
1. Use small Docker images — smaller software footprint reduces vulnerability vectors and speeds up builds.
2. Use the Docker image digest (static SHA256 hash) to ensure deterministic Docker image builds.

Use LTS Node.js with the minimal `alpine` image type:

```dockerfile
FROM node:lts-alpine@sha256:b2da3316acdc2bec442190a1fe10dc094e7ba4121d029cb32075ff59bb27390a
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN npm ci
CMD "npm" "start"
```

## 2) Install only production dependencies in the Node.js Docker image

For production Docker images, install only production dependencies:

```
RUN npm ci --omit=dev
```

This enforces deterministic builds and excludes devDependencies from the image.

## 3) Optimize Node.js tooling for production

Set the `NODE_ENV` environment variable:

```
ENV NODE_ENV production
```

Some frameworks and libraries (e.g., Express) only turn on optimized configuration when `NODE_ENV=production` is set. This has significant performance and security implications.

## 4) Don't run containers as root

The official `node` Docker image includes a least-privileged user named `node`. The complete and proper way of dropping privileges:

```dockerfile
FROM node:lts-alpine@sha256:b2da3316acdc2bec442190a1fe10dc094e7ba4121d029cb32075ff59bb27390a
ENV NODE_ENV production
WORKDIR /usr/src/app
COPY --chown=node:node . /usr/src/app
RUN npm ci --omit=dev
USER node
CMD "npm" "start"
```

Using just `USER node` is not sufficient — files copied with `COPY` are owned by root by default. Use `--chown=node:node`.

## 5) Properly handle events to safely terminate a Node.js Docker web application

Patterns to avoid:
- `CMD "npm" "start"` — npm client doesn't forward signals to the node process
- Shell form notation — container spawns a shell interpreter that may not properly forward signals
- `CMD "node" "server.js"` — Node.js running as PID 1 doesn't respond to SIGINT/SIGTERM properly

Use `dumb-init` as an init process that properly proxies signals:

```dockerfile
FROM node:lts-alpine@sha256:b2da3316acdc2bec442190a1fe10dc094e7ba4121d029cb32075ff59bb27390a
RUN apk add dumb-init
ENV NODE_ENV production
WORKDIR /usr/src/app
COPY --chown=node:node . .
RUN npm ci --omit=dev
USER node
CMD ["dumb-init", "node", "server.js"]
```

## 6) Graceful tear down for your Node.js web applications

Set event handlers for termination signals to allow graceful shutdown:

```javascript
async function closeGracefully(signal) {
   console.log(`Received signal to terminate: ${signal}`)
   await fastify.close()
   // await db.close() if we have a db connection
   process.exit()
}
process.on('SIGINT', closeGracefully)
process.on('SIGTERM', closeGracefully)
```

## 7) Find and fix security vulnerabilities in your Node.js docker image

See Docker Security Cheat Sheet — Use static analysis tools.

## 8) Use multi-stage builds

Multi-stage builds separate building from the production image, avoiding sensitive information leakage.

### Prevent sensitive information leak

Avoid embedding secrets like `NPM_TOKEN` in Dockerfile — they appear in `docker history` output.

### Multi-stage build example

```dockerfile
# The build image
FROM node:latest AS build
ARG NPM_TOKEN
WORKDIR /usr/src/app
COPY package*.json /usr/src/app/
RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > .npmrc && \
   npm ci --omit=dev && \
   rm -f .npmrc

# The production image
FROM node:lts-alpine@sha256:b2da3316acdc2bec442190a1fe10dc094e7ba4121d029cb32075ff59bb27390a
RUN apk add dumb-init
ENV NODE_ENV production
USER node
WORKDIR /usr/src/app
COPY --chown=node:node --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node . /usr/src/app
CMD ["dumb-init", "node", "server.js"]
```

The `NPM_TOKEN` is not visible in `docker history` of the production image because it doesn't exist there.

## 9) Keeping unnecessary files out of your Node.js Docker images

Use a `.dockerignore` file:

```
.dockerignore
node_modules
npm-debug.log
Dockerfile
.git
.gitignore
```

Benefits:
- Skips potentially modified copies of `node_modules/`.
- Prevents secrets exposure (`.env`, `aws.json` files).
- Speeds up Docker builds by avoiding cache invalidation.

## 10) Mounting secrets into the Docker build image

Docker supports mounting secrets at build time without including them in the image or its history:

```dockerfile
# The build image
FROM node:latest AS build
WORKDIR /usr/src/app
COPY package*.json /usr/src/app/
RUN --mount=type=secret,mode=0644,id=npmrc,target=/usr/src/app/.npmrc npm ci --omit=dev

# The production image
FROM node:lts-alpine
RUN apk add dumb-init
ENV NODE_ENV production
USER node
WORKDIR /usr/src/app
COPY --chown=node:node --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node . /usr/src/app
CMD ["dumb-init", "node", "server.js"]
```

Build command:
```
docker build . -t nodejs-tutorial --secret id=npmrc,src=.npmrc
```

Add `.npmrc` to `.dockerignore` to ensure it never makes it into the image.
