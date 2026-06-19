---
title: "Awesome Prometheus Alert Rules"
tags: [prometheus, alerting, alertmanager, copy-pasteable, rules, exporters]
sources: [awesome-prometheus-alerts.md]
assets: [awesome-prometheus-alerts-rules.yml]
updated: 2026-05-22
---

# Awesome Prometheus Alert Rules

A community-curated collection of 954 copy-pasteable Prometheus alerting rules across 112 exporters and 13 categories. Source: [samber/awesome-prometheus-alerts](https://github.com/samber/awesome-prometheus-alerts) · site: https://samber.github.io/awesome-prometheus-alerts/

## Conventions

- Alert names: `CamelCase`, prefixed by service (e.g. `HostOutOfMemory`, `KubernetesPodCrashLooping`)
- Severity: `info` / `warning` / `critical`
- Annotations always include `summary` and `description`; description ends with `VALUE = {{ $value }}\n  LABELS = {{ $labels }}`
- `for` absent → fire on first evaluation; typical values: `0m`, `1m`, `2m`, `5m`, `10m`, `15m`
- Inline comments explain non-obvious PromQL choices; heed them before adjusting thresholds
- Full rule data: `raw/assets/awesome-prometheus-alerts-rules.yml`

## Examples by PromQL Pattern

### Simple ratio threshold

```yaml
- alert: HostOutOfMemory
  expr: (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < .10)
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: Host out of memory (instance {{ $labels.instance }})
    description: "Node memory is filling up (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### predict_linear — disk fill prediction

```yaml
# Add ignored mountpoints in node_exporter: --collector.filesystem.ignored-mount-points=^/(sys|proc|dev|run)($|/)
- alert: HostDiskMayFillIn24Hours
  expr: predict_linear(node_filesystem_avail_bytes{fstype!~"^(fuse.*|tmpfs|cifs|nfs)"}[3h], 86400) <= 0 and node_filesystem_avail_bytes > 0
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: Host disk may fill in 24 hours (instance {{ $labels.instance }})
    description: "Filesystem will likely run out of space within the next 24 hours.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

Same pattern for Kubernetes PVCs with a subquery:

```yaml
- alert: KubernetesVolumeFullInFourDays
  expr: predict_linear(kubelet_volume_stats_available_bytes[6h:5m], 4 * 24 * 3600) < 0
  labels:
    severity: critical
  annotations:
    summary: Kubernetes Volume full in four days (instance {{ $labels.instance }})
    description: "Volume under {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is expected to fill up within four days. Currently {{ $value | humanize }}% is available.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### increase/delta on a counter

```yaml
# node_exporter may become unresponsive for minutes after an OOM; alert still triggers.
- alert: HostOomKillDetected
  expr: (delta(node_vmstat_oom_kill[30m]) > 0)
  labels:
    severity: warning
  annotations:
    summary: Host OOM kill detected (instance {{ $labels.instance }})
    description: "OOM kill detected\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

```yaml
- alert: KubernetesPodCrashLooping
  expr: increase(kube_pod_container_status_restarts_total[1m]) > 3
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: Kubernetes pod crash looping (instance {{ $labels.instance }})
    description: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is crash looping\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### deriv — compound direction + magnitude (clock skew)

```yaml
- alert: HostClockSkew
  expr: ( (node_timex_offset_seconds > 0.05  and deriv(node_timex_offset_seconds[5m]) >= 0) or (node_timex_offset_seconds < -0.05 and deriv(node_timex_offset_seconds[5m]) <= 0) )
  for: 10m
  labels:
    severity: warning
  annotations:
    summary: Host clock skew (instance {{ $labels.instance }})
    description: "Clock skew detected. Clock is out of sync. Ensure NTP is configured correctly on this host.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### deriv — trend alert (pipeline failure rate rising)

```yaml
# This metric may not exist in all GitLab versions. Verify against your installation.
- alert: GitlabCiPipelineFailuresIncreasing
  expr: deriv(gitlab_ci_pipeline_failure_reasons[5m]) > 0.05
  for: 10m
  labels:
    severity: warning
  annotations:
    summary: GitLab CI pipeline failures increasing (instance {{ $labels.instance }})
    description: "GitLab CI pipeline failures are increasing on {{ $labels.instance }} ({{ $value }}/s).\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### Simple equality / status label

```yaml
- alert: ElasticsearchClusterRed
  expr: elasticsearch_cluster_health_status{color="red"} == 1
  labels:
    severity: critical
  annotations:
    summary: Elasticsearch Cluster Red (instance {{ $labels.instance }})
    description: "Elastic Cluster Red status\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### probe_success (blackbox / uptime)

```yaml
- alert: BlackboxProbeFailed
  expr: probe_success == 0
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: Blackbox probe failed (instance {{ $labels.instance }})
    description: "Probe failed\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### avg by with label selectors (cert-manager expiry)

```yaml
# ACME certs renew 30 days before expiry; firing at 21 days may indicate issuer misconfiguration.
- alert: CertManagerCertificateExpiringSoon
  expr: avg by (exported_namespace, namespace, name) (certmanager_certificate_expiration_timestamp_seconds - time()) < (21 * 24 * 3600)
  for: 1h
  labels:
    severity: warning
  annotations:
    summary: Cert-Manager certificate expiring soon (instance {{ $labels.instance }})
    description: "The certificate {{ $labels.name }} is expiring in less than 21 days.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### Dead man switch (always-firing alert)

```yaml
- alert: PrometheusAlertmanagerE2eDeadManSwitch
  expr: vector(1)
  labels:
    severity: critical
  annotations:
    summary: Prometheus AlertManager E2E dead man switch (instance {{ $labels.instance }})
    description: "Prometheus DeadManSwitch is an always-firing alert. It's used as an end-to-end test of Prometheus through the Alertmanager.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

## Coverage by Category

| Category                      | Services | Rules |
| ----------------------------- | -------- | ----- |
| Basic resource monitoring     | 13       | 153   |
| Databases                     | 16       | 184   |
| Message brokers               | 5        | 52    |
| Proxies, LBs & service meshes | 8        | 75    |
| Runtimes                      | 6        | 35    |
| Data engineering              | 3        | 30    |
| Orchestrators                 | 5        | 77    |
| CI/CD                         | 5        | 56    |
| Network and security          | 12       | 70    |
| Storage                       | 4        | 21    |
| Cloud providers               | 4        | 33    |
| Observability                 | 9        | 153   |
| Other                         | 3        | 15    |

## Alert Names by Service

### Basic resource monitoring

**Prometheus self-monitoring** (28, embedded exporter): Prometheus job missing, Prometheus target missing, Prometheus all targets missing, Prometheus target missing with warmup time, Prometheus configuration reload failure, Prometheus too many restarts, Prometheus AlertManager job missing, Prometheus AlertManager configuration reload failure, Prometheus AlertManager config not synced, Prometheus AlertManager E2E dead man switch, Prometheus not connected to alertmanager, Prometheus rule evaluation failures, Prometheus template text expansion failures, Prometheus rule evaluation slow, Prometheus notifications backlog, Prometheus AlertManager notification failing, Prometheus target empty, Prometheus target scraping slow, Prometheus large scrape, Prometheus target scrape duplicate, Prometheus TSDB checkpoint creation failures, Prometheus TSDB checkpoint deletion failures, Prometheus TSDB compactions failed, Prometheus TSDB head truncations failed, Prometheus TSDB reload failures, Prometheus TSDB WAL corruptions, Prometheus TSDB WAL truncations failed, Prometheus timeseries cardinality

**Host and hardware** (35, node-exporter): Host out of memory, Host memory under memory pressure, Host Memory is underutilized, Host unusual network throughput in, Host unusual network throughput out, Host disk IO utilization high, Host out of disk space, Host disk may fill in 24 hours, Host out of inodes, Host filesystem device error, Host inodes may fill in 24 hours, Host unusual disk read latency, Host unusual disk write latency, Host high CPU load, Host CPU is underutilized, Host CPU steal noisy neighbor, Host CPU high iowait, Host unusual disk IO, Host context switching high, Host swap is filling up, Host systemd service crashed, Host physical component too hot, Host node overtemperature alarm, Host software RAID insufficient drives, Host software RAID disk failure, Host kernel version deviations, Host OOM kill detected, Host EDAC Correctable Errors detected, Host EDAC Uncorrectable Errors detected, Host Network Receive Errors, Host Network Transmit Errors, Host Network Bond Degraded, Host conntrack limit, Host clock skew, Host clock not synchronising

**S.M.A.R.T Device Monitoring** (8, smartctl-exporter): SMART device temperature warning, SMART device temperature critical, SMART device temperature over trip value, SMART device temperature nearing trip value, SMART status, SMART critical warning, SMART media errors, SMART Wearout Indicator

**IPMI** (17, prometheus-community/ipmi_exporter): IPMI collector down, IPMI temperature sensor warning/critical, IPMI fan speed sensor warning/critical/zero, IPMI voltage sensor warning/critical, IPMI current sensor warning/critical, IPMI power sensor warning/critical, IPMI generic sensor critical, IPMI chassis power off, IPMI chassis drive fault, IPMI chassis cooling fault, IPMI SEL almost full

**Docker containers** (9, google/cAdvisor): Container killed, Container absent, Container High CPU utilization, Container High Memory usage, Container Volume usage, Container high throttle rate, Container high low change CPU usage, Container Low CPU utilization, Container Low Memory usage

**Blackbox** (9, prometheus/blackbox_exporter): Blackbox probe failed, Blackbox configuration reload failure, Blackbox slow probe, Blackbox probe HTTP failure, Blackbox SSL certificate will expire soon/very soon/expired, Blackbox probe slow HTTP, Blackbox probe slow ping

**Windows Server** (5, prometheus-community/windows_exporter): Windows Server collector Error, Windows Server service Status, Windows Server CPU Usage, Windows Server memory Usage, Windows Server disk Space Usage

**VMware** (4, pryorda/vmware_exporter): Virtual Machine Memory Warning/Critical, High Number of Snapshots, Outdated Snapshots

**Proxmox VE** (9, prometheus-pve/prometheus-pve-exporter): PVE node down, PVE VM/CT down, PVE high CPU usage, PVE high memory usage, PVE storage filling up/almost full, PVE guest not backed up, PVE replication failed, PVE cluster not quorate

**Netdata** (9, embedded): Netdata high cpu/memory usage, CPU steal noisy neighbor, low disk space, predicted disk full, MD mismatch cnt, disk reallocated sectors, disk current pending sector, reported uncorrectable disk sectors

**eBPF** (3, cloudflare/ebpf_exporter): eBPF exporter program not attached, eBPF exporter decoder errors, eBPF exporter no enabled configs

**Process Exporter** (10, ncabatoff/process-exporter): Process exporter group down, high memory/CPU/file descriptor/swap usage, file descriptors exhausted, zombie processes, high context switching, high disk write IO, process restarting

**Systemd** (7, prometheus-community/systemd_exporter): Systemd unit failed/inactive, Systemd service crash looping, Systemd too many restarts, Systemd service inactive, Systemd start limit hit, Systemd failed units

### Databases

**MySQL** (14, prometheus/mysqld_exporter): MySQL down, too many connections, high threads running, slow queries, innodb log waits, replication lag/not running/SQL thread not running, storage engine, too many aborted connections, binary log too large, InnoDB force recovery is enabled, InnoDB buffer pool big pages free

**PostgreSQL** (20, prometheus-community/postgres_exporter): PostgreSQL down, too many connections, not enough connections, dead locks, high rollback rate, commit rate, slow queries, replication lag, table not auto vacuumed, table not auto analyzed, transaction ID wraparound, maximum transaction age, deadlocks, query duration too long, unused replication slots, too many dead tuples, split brain, promoted node, settings changed pending restart, exporter error

**SQL Server** (2, Ozarklake/prometheus-mssql-exporter): SQL Server down, SQL Server dead locks

**Oracle Database** (8, iamseth/oracledb_exporter): Oracle down, high sessions, long running queries, slow queries, tablespace full, archivelog is full, no archivelog backups, session limit approaching

**Patroni** (1): Patroni master disappearing

**PGBouncer** (3, spreaker/prometheus-pgbouncer-exporter): PGBouncer down, active clients, waiting clients

**Redis** (12, oliver006/redis_exporter): Redis down, missing backup, replication broken, cluster flapping, disconnected slaves, out of system/configured maxmemory, too many/not enough/rejected connections

**Memcached** (9, prometheus/memcached_exporter): Memcached down, connection limit approaching (>80%/>95%), out of memory errors, memory usage high, high eviction rate, low cache hit rate, connections rejected, items too large

**MongoDB** (17, percona/mongodb_exporter · dcu/mongodb_exporter · stefanprodan/mgob): MongoDB Down, replica member unhealthy, replication lag (Percona/DCU), replication headroom, cursors open/timeouts, too many connections, replication Status 3/6/8/9/10, Mgob backup failed

**Elasticsearch** (19, prometheus-community/elasticsearch_exporter): Heap Usage Too High/warning, disk out of space/low, Cluster Red/Yellow, Healthy Nodes/Data Nodes, relocating shards (immediate/too long), initializing shards (immediate/too long), unassigned shards, pending tasks, no new documents, High Indexing Latency/Rate, High Query Rate/Latency

**OpenSearch** (6): OpenSearch is unhealthy, high heap usage, circuitbreaker tripped, pending tasks, indexing is throttled, inactive shards

**Meilisearch** (2): index is empty, http response time

**Cassandra** (30, instaclustr/cassandra-exporter · criteo/cassandra_exporter): Node unavailable, compaction tasks pending, commitlog pending tasks, compaction/flush writer blocked, connection timeouts, storage exceptions, tombstone dump, client request unavailable/write/read failure (both exporters), hints count, viewwrite latency, authentication failures, node down, repair pending/blocked tasks, cache hit rate key cache

**ClickHouse** (19, embedded): node down, Memory Usage Critical/Warning, Disk Space Low/Critical on Default/Backups, Replica Errors, No Available/Live Replicas, High TCP Connections, Interserver Connection Issues, ZooKeeper Connection Issues, Authentication/Access Denied Errors, rejected/delayed insert queries, zookeeper hardware exception, high network usage, distributed rejected inserts

**CouchDB** (18, gesellix/couchdb-prometheus-exporter): node down, atom memory critical, open databases/OS files critical, 5xx error ratio high, temporary view read rate, Mango queries scanning too many docs/failed invalid index/docs examined high, Replicator manager/queue/reader died, replication failed to start/cluster unstable/read failures, file descriptors high, process restarted, critical log entries

**Solr** (4, embedded): update/query/replication errors, low live node count

### Message brokers

**RabbitMQ** (21, rabbitmq/rabbitmq-prometheus · kbudde/rabbitmq-exporter): node down/not distributed, instances different versions, memory high, file descriptors usage, too many ready/unack/messages in queue, too many/instance too many connections, no queue consumer, unroutable messages, down, cluster down/partition, out of memory, dead letter queue filling up, slow queue consuming, no consumer, too many consumers, inactive exchange

**Zookeeper** (4): Zookeeper Down, missing leader, Too Many Leaders, Not Ok

**Kafka** (4, danielqsj/kafka_exporter · linkedin/Burrow): topics replicas, consumer group lag, topic offset decreased, consumer lag

**Pulsar** (10, embedded): subscription high/very high backlog entries, topic large/very large backlog storage size, high write latency, large message payload, high ledger disk usage, read only bookies, high number of function/sink errors

**Nats** (13, nats-io/prometheus-nats-exporter): high routes count, high memory usage, slow consumers, server down, high CPU usage, high number of connections, high JetStream store/memory usage, high number of subscriptions, high pending bytes, too many errors, JetStream accounts exceeded, leaf node connection issue

### Proxies, load balancers and service meshes

**Nginx** (3, knyar/nginx-lua-prometheus): high HTTP 4xx/5xx error rate, latency high

**Apache** (3, Lusitaniae/apache_exporter): down, workers load, restart

**HaProxy** (30, embedded ≥v2 · prometheus/haproxy_exporter <v2): high HTTP 4xx/5xx error rate backend/server (v1+v2), server response errors, backend/server connection errors, backend max active session >80%, pending requests, HTTP slowing down, retry high, no alive backends, frontend security blocked requests, server healthcheck failure, down, backend/server down (v1+v2 variants)

**Traefik** (6, embedded v1+v2): service down, high HTTP 4xx/5xx error rate service/backend

**Caddy** (3, embedded): Reverse Proxy Down, high HTTP 4xx/5xx error rate service

**Envoy** (19, built-in): server not live, high memory usage, high downstream HTTP 5xx/4xx error rate, downstream connections overflowing, cluster membership empty/degraded, high cluster upstream connection failures/request timeout/5xx error rate, cluster health check failures, outlier detection ejections active, listener SSL connection errors, global downstream connections overflowing, SSL certificate expiring soon/expired, circuit breaker tripped, no healthy upstream, high downstream request timeout rate

**Linkerd** (1, embedded): high error rate

**Istio** (10, embedded): Kubernetes gateway availability drop, Pilot high push error rate, Mixer Prometheus dispatches low, high/low total request rate, high 4xx/5xx error rate, high request latency, latency 99 percentile, Pilot Duplicate Entry

### Runtimes

**PHP-FPM** (1): max-children reached

**JVM** (12, java-client): memory/non-heap memory filling up, GC time too high, threads deadlocked, thread count high, threads BLOCKED, old gen GC frequency, direct buffer pool filling up, objects pending finalization, file descriptors exhaustion, class loading anomaly, compilation time spike

**Golang** (10, client_golang): goroutine count high, GC duration high, memory usage high, thread count high, heap objects count high, GC CPU fraction high, goroutine spike, heap in-use growing, memory leak, stack memory high

**Ruby** (5, prometheus_exporter): heap live/free slots high, major GC rate high, RSS high, allocated objects spike

**Python** (5, client_python): GC objects uncollectable, GC collections high, file descriptors exhaustion, GC generation 2 collections high, virtual memory high

**Sidekiq** (2, Strech/sidekiq-prometheus-exporter): queue size, scheduling latency too high

### Data engineering

**Apache Flink** (12, built-in Prometheus reporter): job is not running, no TaskManagers registered, all task slots used, job restart increasing, checkpoint failures/duration high, task backpressured/high backpressure time, TaskManager/JobManager heap memory high, TaskManager GC time high, no records processed

**Apache Spark** (8, PrometheusServlet + PrometheusResource): no alive workers, too many waiting apps, worker memory/cores exhausted, executor high GC time, executor all tasks failing, high task failure rate, high disk spill

**Hadoop** (10, hadoop/jmx_exporter): Name Node Down, Resource Manager Down, Data Node Out Of Service, HDFS Disk Space Low, Map Reduce Task Failures, Resource Manager Memory High, YARN Container Allocation Failures, HBase Region Count High, HBase Region Server Heap Low, HBase Write Requests Latency High

### Orchestrators

**Kubernetes** (37, kube-state-metrics): Node not ready/scheduling disabled/memory pressure/disk pressure/network unavailable/out of pod capacity, Container oom killer, Job failed/not starting, CronJob failing/suspended/too long, PersistentVolumeClaim pending, Volume out of disk space/full in four days, PersistentVolume error, StatefulSet down, HPA scale inability/metrics unavailability/scale maximum/underutilized, Pod not healthy/crash looping, ReplicaSet/Deployment/StatefulSet replicas mismatch, Deployment/StatefulSet generation mismatch, StatefulSet update not rolled out, DaemonSet rollout stuck/misscheduled, Job slow completion, API server errors/client errors/latency, client certificate expires next week/soon

**Nomad** (4, embedded): job failed/lost/queued, blocked evaluation

**Consul** (3, prometheus/consul_exporter): service healthcheck failed, missing master node, agent unhealthy

**Etcd** (13, embedded): insufficient Members, no Leader, high number of leader changes, high number of failed GRPC requests (warning/critical), GRPC requests slow, high number of failed HTTP requests (warning/critical), HTTP requests slow, member communication slow, high number of failed proposals, high fsync/commit durations

**OpenStack** (20, openstack-exporter/openstack-exporter): exporter down, Nova/Neutron/Cinder agent down, hypervisor high vCPU/memory/disk usage, Nova tenant vCPU/memory/instance quota nearly exhausted, Cinder tenant volume quota nearly exhausted/pool low free capacity, Neutron floating IPs not active/routers not active/subnet IP pool exhaustion/ports without IPs, load balancer not online, Nova instances/Cinder volumes in error state, placement resource high usage

### CI/CD

**Jenkins** (8, Metric plugin): node offline, no node online, healthcheck, outdated plugins, builds health score, run failure total, build tests failing, last build failed

**ArgoCD** (2, embedded): service not synced, service unhealthy

**FluxCD** (4, embedded): Kustomization Failure, HelmRelease Failure, Source Issue, Image Issue

**GitLab CI** (30, GitLab built-in · Workhorse · Gitaly): Puma high queued connections/no available pool capacity/workers not running, high HTTP error rate/request latency, Sidekiq jobs failing/queue too large/high job completion time/high queue latency, database connection pool saturation/dead connections/waiting, CI pipeline creation slow/failures increasing/runner authentication failures, high memory usage, Ruby heap fragmentation, rack uncaught errors, version mismatch, high file descriptor usage, Ruby threads saturated, Workhorse high error rate/latency/in-flight requests, Gitaly high gRPC error rate/resource exhausted/high RPC latency/CPU throttled/authentication failures/circuit breaker tripped

**Spinnaker** (12, embedded): circuit breaker open, Orca queue backing up/message lag high, dead messages, zombie executions, thread pool exhaustion, polling monitor items over threshold/failures, high API error rate, API rate limit throttling, Clouddriver high error rate, AWS rate limiting

### Network and security

**SpeedTest** (2): Slow Internet Download/Upload

**SSL/TLS** (4, ssl_exporter): certificate probe failed, OCSP status unknown, certificate revoked, certificate expiry <7 days

**cert-manager** (4, embedded): absent, certificate expiring soon/not ready, hitting ACME rate limits

**Juniper** (3, czerwonk/junos_exporter): switch down, critical/warning Bandwidth Usage 1GiB

**CoreDNS** (1, embedded): Panic Count

**Freeswitch** (3, znerol/prometheus-freeswitch-exporter): down, Sessions Warning/Critical

**Hashicorp Vault** (4, embedded): sealed, too many pending/infinity tokens, cluster health

**Keycloak** (6, aerogear/keycloak-metrics-spi): high login failure rate, no successful logins, high token refresh error rate, high code-to-token exchange error rate, high registration failure rate, slow request response time

**Cloudflare** (2, lablabs/cloudflare-exporter): http 4xx/5xx error rate

**SNMP** (7, prometheus/snmp_exporter): target down, interface down, high inbound/outbound error rate, high bandwidth usage inbound/outbound, device restarted

**Cilium** (31, embedded): agent unreachable nodes/health endpoints, agent failing controllers/endpoint failures/regeneration failures/update/create failure, map operation failures, BPF map pressure, conntrack table full/failed GC, NAT table full, high denied/drop rate, policy map pressure/import errors/implementation delay, node-local/cluster high identity allocation, operator exhausted/low available IPAM IPs/interface creation failures, agent API/Kubernetes client errors, ClusterMesh remote cluster not ready/failing, KVStoreMesh remote cluster not ready/failing/sync errors, Hubble lost events/high DNS error rate

**WireGuard** (3, MindFlavor/prometheus_wireguard_exporter): peer handshake too old/never established, no traffic on peer

### Storage

**Ceph** (13, embedded): State, monitor clock skew/low space, OSD Down/near full/reweighted/high latency, PG down/incomplete/inconsistent/activation long/backfill full/unavailable

**ZFS** (4, node-exporter · ZFS exporter): offline pool, pool out of space/unhealthy, collector failed

**OpenEBS** (1, embedded): used pool capacity

**Minio** (3, embedded): cluster disk offline, node disk offline, disk space usage

### Cloud providers

**AWS CloudWatch** (13, prometheus/cloudwatch_exporter): exporter scrape error/slow scrape, API high request rate, EC2 high CPU utilization, RDS low free storage space/high CPU utilization/high database connections, SQS queue messages visible/message age too old, ALB unhealthy targets/high 5xx error rate/high target response time, Lambda high error rate

**Google Cloud Stackdriver** (5, prometheus-community/stackdriver_exporter): exporter scrape error/slow scrape/scrape errors increasing/high API calls/scrape stale

**DigitalOcean** (10, metalmatze/digitalocean_exporter): droplet down, account not active, database down, Kubernetes cluster down, load balancer down/no backends, floating IP not assigned, active incidents, exporter collection errors, droplet limit approaching

**Azure** (5, webdevops/azure-metrics-exporter): exporter request errors/high error rate, API read/write rate limit approaching, exporter slow collection

### Observability

**Thanos** (45, Compactor · Query · Receiver · Sidecar · Store · Rule · Bucket Replicate): Multiple Running, Halted, High Compaction Failures, Bucket High Operation Failures, Has Not Run (Compactor); Http Request Query/Range Error Rate High, Grpc Server/Client Error Rate, High DNS Failures, Instant/Range Latency High, Overload (Query); Http Request Error/Latency High, High Replication/Forward Request Failures, High Hashring File Refresh Failures, Config Reload Failure, No Upload (Receive); Sidecar Bucket Operations Failed, No Connection To Started Prometheus; Store Grpc Error Rate, Series Gate Latency High, Bucket High Operation Failures, Objstore Operation Latency High; Rule Queue Dropping Alerts/Sender Failing Alerts/High Rule Evaluation Failures/Warnings/Latency, Rule Grpc Error Rate/Config Reload Failure/Query High DNS Failures/Alertmanager High DNS Failures/No Evaluation For 10 Intervals; No Rule Evaluations; Bucket Replicate Error Rate/Run Latency; Is Down (per component)

**Loki** (4, embedded): process too many restarts, request errors/panic/latency

**Promtail** (2, embedded): request errors, request latency

**Cortex** (6, embedded): ruler configuration reload failure, not connected to Alertmanager, notifications being dropped/errors, ingester unhealthy, frontend queries stuck

**Grafana Tempo** (18, embedded): distributor/live store/metrics generator unhealthy, compactions failing, polls failing, tenant index failures/no builders/too old, block list rising quickly, bad overrides, user configurable overrides reload failing, compaction too many outstanding blocks (warning/critical), distributor usage tracker errors, metrics generator processor updates failing/service graphs dropping spans/collections failing, memcached errors elevated

**Grafana Mimir** (49, embedded): ingester unhealthy, request errors, inconsistent/bad runtime config, scheduler queries stuck, cache request errors, KV store failure, memory map areas too high, ingester instance/ruler instance has no tenants/rule groups, ingested data too far in the future, store gateway too many failed operations/not synced/no synced tenants, ring members mismatch, ingester reaching series/tenants limit (warning/critical), reaching TCP connections limit, distributor inflight requests high, ingester TSDB head compaction/truncation/checkpoint creation/deletion/WAL truncation/WAL writes failed, bucket index not updated, compactor not cleaning up blocks/not running compaction/consecutive failures/out of disk space/not uploaded blocks/skipped blocks, ruler too many failed pushes/queries/missed evaluations/failed ring check, alertmanager sync configs/ring check/state merge/replication/persist state/initial sync/instance has no tenants failing, gossip members count too high/low, go threads too high (warning/critical)

**Grafana Alloy** (1, embedded): service down

**OpenTelemetry Collector** (12, embedded): down, receiver refused spans/metric points/log records, exporter failed spans/metric points/log records, exporter queue nearly full, processor refused spans/metric points, high memory usage, OTLP receiver errors

**Jaeger** (16, embedded v2+ · legacy <v2): high storage error rate, slow storage operations, query service high error rate/slow responses, storage completely unavailable, slow single trace retrieval, service discovery errors, no storage reads succeeding, agent HTTP server errors, client RPC request errors, client/agent spans dropped, collector dropping spans, sampling/throttling update failing, query request failures

### Other

**APC UPS** (6, mdlayher/apcupsd_exporter): Battery nearly empty, Less than 15 Minutes of battery time remaining, AC input outage, low battery voltage, high temperature, high load

**Graph Node** (6, embedded): Provider failed — net_version failed/genesis failed/net_version timeout/genesis timeout, Store connection slow/very slow

**LiteLLM** (3): provider spend over budget, proxy failed requests rate high, request latency p95 high

## Guides

- **AlertManager Config** — Prometheus and Alertmanager configuration examples and troubleshooting.
- **Blackbox Exporter** — Worldwide probes, Prometheus config, geohash/Grafana map setup.
- **Sleep Peacefully** — Time-based alert suppression and timezone-aware PromQL patterns using `day_of_week()` and `hour()`.

## Usage

Rules are copy-pasted into Prometheus alerting rule files. Thresholds are sensible defaults but may need tuning per workload. License: Creative Commons CC BY 4.0.

## Related

- [Prometheus Alerting Rules config reference](../sources/prometheus-alerting-rules.md)
- [Prometheus Alerting best practices](../sources/prometheus-alerting.md)
- [Alertmanager concept](../concepts/alertmanager.md)
- [Prometheus entity](../entities/prometheus.md)
