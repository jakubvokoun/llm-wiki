---
title: "Tilt with Docker Compose"
tags: [tilt, docker-compose, docker]
sources: [tilt-docker-compose]
updated: 2026-07-01
---

# Tilt with Docker Compose

[[tilt|Tilt]] can drive a **[[docker|Docker Compose]]** dev environment as an alternative to [[kubernetes|Kubernetes]]: organize each Compose service in the Tilt dashboard, control when/how it runs, and add [[tilt-live-update|Live Update]] in place. Example: [tilt-example-docker-compose](https://github.com/tilt-dev/tilt-example-docker-compose).

## Getting started

Point Tilt at an existing Compose file in the [[tiltfile|Tiltfile]]:

```python
docker_compose("./docker-compose.yml")
```

Then `tilt up`. **Important difference from `docker-compose up`:** Tilt leaves services running when it exits — use `tilt down` to stop them.

## Using `docker_build`

Tilt automatically uses the `build` config from Compose, but calling `docker_build` lets Tilt apply its own update optimizations. Tilt matches the image name from `docker-compose.yml`:

```python
docker_compose('docker-compose.yml')
docker_build('tilt.dev/express-redis-app', '.')
```

## Adding `live_update`

```python
docker_compose('docker-compose.yml')
docker_build('tilt.dev/express-redis-app', '.',
  live_update = [
    sync('.', '/var/www/app'),
    run('npm i', trigger='package.json'),
    restart_container()          # note: Compose uses restart_container(), not the restart_process extension
  ])
```

See [[tilt-live-update-reference]] for step semantics.

## Multiple Compose files & overrides

```python
docker_compose(["./docker-compose.yml", "./docker-compose.override.yml"])
```

`docker_compose` also accepts a `blob`, so you can inject inline overrides (e.g. driven by [[tilt-tiltfile-config|config flags]]) via `encode_yaml({...})`.

## Organizing services — `dc_resource`

```python
dc_resource('redis', labels=["database"])   # group services with labels
dc_resource('app',   labels=["server"])
dc_resource('storybook', auto_init=False)    # don't run at startup
```

Debug outside Tilt with the normal `docker-compose` CLI, since Tilt uses Compose to run the services.

Related: [[tilt]], [[tiltfile]], [[tilt-live-update]], [[tilt-ci]].
