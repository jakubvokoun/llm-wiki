---
source_url: https://docs.tilt.dev/snippets.html
fetched: 2026-07-01
---

# Tiltfile Snippets

> **Want to contribute?**
> Follow [this guide](https://github.com/tilt-dev/tilt.build/blob/master/contributing-snippets.md) to find out how to submit your own snippets!

### Filter by tags

* [Permalink](#snip_docker_build_simple)

  ### Build a Docker image

  Register an image to build with docker_build

  ```
  # docker build -t companyname/frontend ./frontend
  docker_build("companyname/frontend", "frontend")
  ```

  ##### Reference

  [Tiltfile Concepts: Build Images](/tiltfile_concepts.html#build)

* [Permalink](#snip_docker_build_inline)

  ### Build an image with inline Dockerfile

  Build an nginx image with provided static assets via an inline Dockerfile

  ```
  dockerfile="""
  FROM nginx:latest
  COPY . /usr/share/nginx/html
  """
  docker_build("companyname/assets", "./assets", dockerfile_contents=dockerfile)
  ```

* [Permalink](#snip_k8s_yaml_simple)

  ### Apply K8s YAML

  Apply K8s YAML manifest files

  ```
  # one static YAML file
  k8s_yaml('k8s/app.yaml')

  # multiple YAML files in one call
  k8s_yaml(['k8s/secrets.yaml', 'k8s/configmaps.yaml', 'k8s/crds.yaml'])
  ```

  ##### Reference

  [Tiltfile Concepts: Deploy](/tiltfile_concepts.html#deploy)

* [Permalink](#snip_k8s_yaml_kustomize)

  ### Apply K8s Kustomize templates

  Apply K8s manifests results from Kustomize

  ```
  k8s_yaml(kustomize('kustomize_dir'))
  ```

  ##### Reference

  [Tiltfile Concepts: Deploy](/tiltfile_concepts.html#deploy)

* [Permalink](#snip_k8s_yaml_helm)

  ### Apply K8s Helm templates

  Apply K8s manifests results from a local Helm chart

  ```
  k8s_yaml(helm('chart_dir'))
  ```

  ##### Reference

  [Tiltfile Concepts: Deploy](/tiltfile_concepts.html#deploy)

* [Permalink](#snip_k8s_yaml_custom)

  ### Apply output from custom command

  Run a custom command to generate YAML to apply to the cluster

  ```
  text = local('./foo.py') # runs command foo.py
  k8s_yaml(text)
  ```

  ##### Reference

  [Tiltfile Concepts: Generated K8s YAML](/tiltfile_concepts.html#custom-commands)

* [Permalink](#snip_k8s_resource_port_forward)

  ### Create a port-forward to a container

  Set up a port-forward to a resource's default container

  ```
  # connect localhost:9000 to container port 9000
  k8s_resource(
    workload='frontend',
    port_forwards=9000
  )
  ```

  ##### Reference

  [Tiltfile Concepts: Configuring K8s Resources](/tiltfile_concepts.html#configuring-kubernetes-resources)

* [Permalink](#snip_k8s_resource_config1)

  ### Configure a K8s resource

  Associate a secret and a volume to a service

  ```
  k8s_resource(
    workload='frontend',
    objects=['frontend:secret', 'frontend:volume']
  )
  ```

  ##### Reference

  [Tiltfile Concepts: Configuring K8s Resources](/tiltfile_concepts.html#configuring-kubernetes-resources)

* [Permalink](#snip_k8s_resource_config2)

  ### Create a K8s resource from existing objects

  Make a new resource by grouping objects necessary for cluster setup

  ```
  k8s_resource(
    objects=['my-ns:namespace', 'kafka:crd', 'some-ingress:ingress'],
    new_name='cluster-setup',
  )
  # Wait to deploy this resource until cluster setup is complete
  k8s_resource('myapp', resource_deps=['cluster-setup'])
  ```

  ##### Reference

  [Tiltfile Concepts: Configuring K8s Resources](/tiltfile_concepts.html#configuring-kubernetes-resources)

* [Permalink](#snip_k8s_deployment)

  ### Create a K8s deployment

  Deploy a redis server with the "deployment" extension

  ```
  # Load the 'deployment' extension
  load('ext://deployment', 'deployment_create')
  # Create a redis deployment and service with a readiness probe
  deployment_create(
    'redis',
    ports='6379',
    readiness_probe={'exec':{'command':['redis-cli','ping']}}
  )
  ```

  ##### Reference

  [Extension: deployment](https://github.com/tilt-dev/tilt-extensions/tree/master/deployment)

* [Permalink](#snip_k8s_secret)

  ### Create a K8s secret

  Create a secret with the "secret" extension

  ```
  # Load the 'secret' extension
  load('ext://secret', 'secret_create_generic', 'secret_from_dict')
  # Create a pgpass secret from a local file
  secret_create_generic('pgpass', from_file='.pgpass=./.pgpass')
  # Create a secret from a dict
  k8s_yaml(secret_from_dict("secrets", inputs={'SOME_TOKEN': os.getenv('SOME_TOKEN')}))
  ```

  ##### Reference

  [Extension: secret](https://github.com/tilt-dev/tilt-extensions/tree/master/secret)

* [Permalink](#snip_k8s_configmap)

  ### Create a K8s configmap

  Create a configmap with the "configmap" extension

  ```
  # Load the 'configmap' extension
  load('ext://configmap', 'configmap_create')
  # Create a configmap from a file
  configmap_create('grafana-config', from_file=['grafana.ini=./grafana.ini'])
  # Create a configmap from a dict
  k8s_yaml(configmap_from_dict('app-env', inputs={'HOST': '0.0.0.0', 'PORT': '5000'}))
  ```

  ##### Reference

  [Extension: configmap](https://github.com/tilt-dev/tilt-extensions/tree/master/configmap)

* [Permalink](#snip_docker_compose)

  ### Build and deploy with Docker Compose

  Launch services using an existing Compose file

  ```
  docker_compose('./docker-compose.yml')
  ```

  ##### Reference

  [API: docker_compose()](/api.html#api.docker_compose)

* [Permalink](#snip_docker_compose_override)

  ### Deploy Docker Compose services with overrides

  Layer overrides on top of an existing Compose file

  ```
  services = {'app': {'environment': {'DEBUG': 'true'}}}
  docker_compose(['docker-compose.yml', encode_yaml({'services': services})])
  ```

  ##### Reference

  [API: docker_compose()](/api.html#api.docker_compose)

* [Permalink](#snip_local_yarn)

  ### Run a local Yarn command

  Run Yarn every time dependencies change

  ```
  local_resource('yarn', cmd='yarn install', deps=['package.json', 'yarn.lock'])
  ```

  ##### Reference

  [Local Resource](/local_resource.html)

* [Permalink](#snip_local_go_server)

  ### Build and run a local go server

  Set up a server that rebuilds/relaunches on changes

  ```
  local_resource(
    'local-myserver',
    cmd='go build ./cmd/myserver',
    serve_cmd='./myserver --port=8001',
    deps=['cmd/myserver']
  )
  ```

  ##### Reference

  [Local Resource: serve_cmd](/local_resource.html#serve_cmd)

* [Permalink](#snip_local_nodejs_server)

  ### Install and run a local nodejs server

  Install dependencies and start the server

  ```
  local_resource(
    'local-js-server',
    cmd='yarn install',
    deps=['package.json', 'yarn.lock'],
    serve_cmd='yarn start'
  )
  ```

  ##### Reference

  [Local Resource: serve_cmd](/local_resource.html#serve_cmd)

* [Permalink](#snip_local_kube_logs)

  ### Show the K8s API server logs

  Create a resource to follow the K8s API server logs

  ```
  api_pod = 'kube-apiserver-docker-desktop' # For Docker Desktop cluster
  # api_pod = 'kube-apiserver-kind-control-plane' # for KIND cluster
  local_resource('kube-logs', serve_cmd='kubectl logs -f -n kube-system {}'.format(api_pod))
  ```

  ##### Reference

  [Local Resource: serve_cmd](/local_resource.html#serve_cmd)

* submitted by [nicks](https://github.com/nicks)

  [Permalink](#snip_down)

  ### Handle tilt down

  Do a custom action on 'tilt down'

  ```
  if config.tilt_subcommand == 'down':
    print('Goodbye world!')
  ```

* [Permalink](#snip_docker_build_existing_k8s_resource)

  ### Build an image for an existing K8s resource

  Configure live-update and inject the image into a deployment not managed by Tilt

  ```
  docker_build(
    "myappimage",
    "myapp"
    live_update=[sync("./myapp", "/app")]
  )
  k8s_custom_deploy(
    "myapp",
    apply_cmd="""
      kubectl -v=0 set image deployment/myapp *=$TILT_IMAGE_0 > /dev/null && \
        kubectl get deployment/myapp -o yaml
    """
    delete_cmd="echo Myapp managed outside of Tilt",
    image_deps=["myappimage"]
  )
  ```

* [Permalink](#snip_k8s_build_deployment)

  ### Build and deploy an app to K8s

  Build and deploy without YAML using the "deployment" extension

  ```
  load('ext://deployment', 'deployment_create')
  docker_build(
    'myapp',
    './myapp',
    # For a Dockerfile that has a 'COPY . /app' statement in it
    live_update=[sync('./myapp', '/app')]
  )
  deployment_create('myapp')
  ```

  ##### Reference

  [Extension: deployment](https://github.com/tilt-dev/tilt-extensions/tree/master/deployment)

* [Permalink](#snip_local_make)

  ### Trigger a Makefile task

  Execute a Makefile task on-demand with a trigger

  ```
  # To run: `tilt trigger mytask` or via trigger button 🔃 in the UI
  local_resource(
    "mytask",
    cmd="make mytask",
    trigger_mode=TRIGGER_MODE_MANUAL,
    auto_init=False,
    labels=["makefile"],
  )
  ```

  ##### Reference

  [Local Resource](/local_resource.html)

* [Permalink](#snip_local_tiltfile)

  ### Enable per-developer customizations

  Conditionally load a local.tiltfile for additional functionality

  ```
  # Remember to add `local.tiltfile` to .gitignore
  if os.path.exists('local.tiltfile'):
    load_dynamic('local.tiltfile')
  ```

  ##### Reference

  [Load Dynamic](/api.html#api.load_dynamic)

* [Permalink](#snip_min_k8s_version)

  ### Enforce a Kubernetes version range

  Require a minimum and/or maximum version of Kubernetes for compatibility

  ```
  load("ext://min_k8s_version", "min_k8s_version", "max_k8s_version")
  min_k8s_version("1.18.3")
  max_k8s_version("1.22.0")
  ```

  ##### Reference

  [Extension: min_k8s_version](https://github.com/tilt-dev/tilt-extensions/tree/master/min_k8s_version)

* [Permalink](#snip_min_tilt_version)

  ### Enforce a minimum Tilt version

  Require a minimum version of Tilt for feature availability

  ```
  version_settings(check_updates=True, constraint='>=0.23.7')
  ```

  ##### Reference

  [API: version_settings()](/api.html#api.version_settings)

* [Permalink](#snip_require_local_tool)

  ### Ensure a tool is installed locally

  Check that a command exists in `PATH` or fail the Tiltfile load.

  ```
  # block Tiltfile execution if missing required tool (e.g. Helm)
  def require_tool(tool, msg=None):
      tool = shlex.quote(tool)
      if not msg:
          msg = '%s is required but was not found in PATH' % tool
      local(
          command='command -v %s >/dev/null 2>&1 || { echo >&2 "%s"; exit 1; }' % (tool, msg),
          command_bat=[
              "powershell.exe",
              "-Noninteractive",
              "-Command",
              '& {{if (!(Get-Command %s -ErrorAction SilentlyContinue)) {{ Write-Error "%s"; exit 1 }}}}' % (tool, msg),
          ],
          quiet=True,
      )

  require_tool("helm")
  ```

  ##### Reference

  [Local Resource](/local_resource.html)

* [Permalink](#snip_socat)

  ### Create a socat tunnel

  Expose a remote database server on a local port

  ```
  local_resource(
    'socat-tunnel',
    # Change `brew install` to your preferred way of installing socat
    cmd='which socat || brew install socat',
    serve_cmd='socat TCP-LISTEN:{port},reuseaddr,fork TCP:{remote}:{port}'.format(port=3306,remote='remote-mysql')
  )
  ```

  ##### Reference

  [Local Resource](/local_resource.html)

* [Permalink](#snip_update_control_full_manual)

  ### Full manual control for resource

  Configure a resource to only start/update when triggered via web UI
  (works with all resource types, e.g. k8s_resource, local_resource, and dc_resource).
  Suggested use case: on-demand jobs/tasks.

  ```
  k8s_resource("my-resource", auto_init=False, trigger_mode=TRIGGER_MODE_MANUAL)

  local_resource("my-resource", serve_cmd="./run.sh", auto_init=False, trigger_mode=TRIGGER_MODE_MANUAL)

  dc_resource("my-resouce", auto_init=False, trigger_mode=TRIGGER_MODE_MANUAL)
  ```

  ##### Reference

  [Manual Update Control](/manual_update_control.html)

* [Permalink](#snip_update_control_ignore_changes)

  ### Ignore file changes for resource

  Configure a resource to start automatically but only update if triggered manually via web UI
  (works with all resource types, e.g. k8s_resource, local_resource, and dc_resource).
  Suggested use case: required services for project that you are not actively making changes to.

  ```
  k8s_resource("my-resource", auto_init=True, trigger_mode=TRIGGER_MODE_MANUAL)

  local_resource("my-resource", serve_cmd="./run.sh", auto_init=True, trigger_mode=TRIGGER_MODE_MANUAL)

  dc_resource("my-resouce", auto_init=True, trigger_mode=TRIGGER_MODE_MANUAL)
  ```

  ##### Reference

  [Manual Update Control](/manual_update_control.html)

* [Permalink](#snip_update_control_only_changes)

  ### Wait to launch resource until first file change

  Configure a resource to not launch until the first file dependency changes after launching `tilt up`
  (works with all resource types, e.g. k8s_resource, local_resource, and dc_resource).
  Suggested use case: linters, unit tests.

  ```
  # Kubernetes `my-resource` will wait for a file in the image build context to change before start
  k8s_resource("my-resource", auto_init=False, trigger_mode=TRIGGER_MODE_AUTO)

  # Local resource `my-resource` will wait for a file in `./my-resource` to change before start
  local_resource("my-resource", serve_cmd="./run.sh", auto_init=False, trigger_mode=TRIGGER_MODE_AUTO, deps=['./my-resource'])

  # Docker Compose `my-resource` will wait for a file in the image build context to change before start
  dc_resource("my-resouce", auto_init=False, trigger_mode=TRIGGER_MODE_AUTO)
  ```

  ##### Reference

  [Manual Update Control](/manual_update_control.html)
