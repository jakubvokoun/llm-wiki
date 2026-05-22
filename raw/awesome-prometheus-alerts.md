# Awesome Prometheus Alert Rules

954 copy-pasteable Prometheus alerting rules.
Find, copy, and deploy alerts in seconds.

954 alert rules · 112 exporters · 13 categories

## Popular services

[Prometheus self-monitoring](/awesome-prometheus-alerts/rules/basic-resource-monitoring/prometheus-self-monitoring/)  [Host and hardware](/awesome-prometheus-alerts/rules/basic-resource-monitoring/host-and-hardware/)  [Kubernetes](/awesome-prometheus-alerts/rules/orchestrators/kubernetes/)  [MySQL](/awesome-prometheus-alerts/rules/databases/mysql/)  [PostgreSQL](/awesome-prometheus-alerts/rules/databases/postgresql/)  [Redis](/awesome-prometheus-alerts/rules/databases/redis/)  [MongoDB](/awesome-prometheus-alerts/rules/databases/mongodb/)  [Elasticsearch](/awesome-prometheus-alerts/rules/databases/elasticsearch/)  [RabbitMQ](/awesome-prometheus-alerts/rules/message-brokers/rabbitmq/)  [Nginx](/awesome-prometheus-alerts/rules/proxies-load-balancers-and-service-meshes/nginx/)  [Kafka](/awesome-prometheus-alerts/rules/message-brokers/kafka/)  [Docker containers](/awesome-prometheus-alerts/rules/basic-resource-monitoring/docker-containers/)

## Browse by category

### Basic resource monitoring

13 services · 153 rules

- Prometheus self-monitoring — 28 rules
- Host and hardware — 35 rules (node-exporter)
- S.M.A.R.T Device Monitoring — 8 rules (smartctl-exporter)
- IPMI — 17 rules (prometheus-community/ipmi_exporter)
- Docker containers — 9 rules (google/cAdvisor)
- Blackbox — 9 rules (prometheus/blackbox_exporter)
- Windows Server — 5 rules (prometheus-community/windows_exporter)
- VMware — 4 rules (pryorda/vmware_exporter)
- Proxmox VE — 9 rules (prometheus-pve/prometheus-pve-exporter)
- Netdata — 9 rules (Embedded exporter)
- eBPF — 3 rules (cloudflare/ebpf_exporter)
- Process Exporter — 10 rules (ncabatoff/process-exporter)
- Systemd — 7 rules (prometheus-community/systemd_exporter)

### Databases

16 services · 184 rules

- MySQL — 14 rules (prometheus/mysqld_exporter)
- PostgreSQL — 20 rules (prometheus-community/postgres_exporter)
- SQL Server — 2 rules (Ozarklake/prometheus-mssql-exporter)
- Oracle Database — 8 rules (iamseth/oracledb_exporter)
- Patroni — 1 rule (Embedded exporter, Patroni >= 2.1.0)
- PGBouncer — 3 rules (spreaker/prometheus-pgbouncer-exporter)
- Redis — 12 rules (oliver006/redis_exporter)
- Memcached — 9 rules (prometheus/memcached_exporter)
- MongoDB — 17 rules (percona/mongodb_exporter · dcu/mongodb_exporter · stefanprodan/mgob)
- Elasticsearch — 19 rules (prometheus-community/elasticsearch_exporter)
- OpenSearch — 6 rules (opensearch-project/opensearch-prometheus-exporter)
- Meilisearch — 2 rules (Embedded exporter)
- Cassandra — 30 rules (instaclustr/cassandra-exporter · criteo/cassandra_exporter)
- Clickhouse — 19 rules (Embedded Exporter)
- CouchDB — 18 rules (gesellix/couchdb-prometheus-exporter)
- Solr — 4 rules (embedded exporter)

### Message brokers

5 services · 52 rules

- RabbitMQ — 21 rules (rabbitmq/rabbitmq-prometheus · kbudde/rabbitmq-exporter)
- Zookeeper — 4 rules (cloudflare/kafka_zookeeper_exporter · dabealu/zookeeper-exporter)
- Kafka — 4 rules (danielqsj/kafka_exporter · linkedin/Burrow)
- Pulsar — 10 rules (embedded exporter)
- Nats — 13 rules (nats-io/prometheus-nats-exporter)

### Proxies, load balancers and service meshes

8 services · 75 rules

- Nginx — 3 rules (knyar/nginx-lua-prometheus)
- Apache — 3 rules (Lusitaniae/apache_exporter)
- HaProxy — 30 rules (Embedded exporter (HAProxy >= v2) · prometheus/haproxy_exporter (HAProxy < v2))
- Traefik — 6 rules (Embedded exporter v2 · Embedded exporter v1)
- Caddy — 3 rules (Embedded exporter)
- Envoy — 19 rules (Built-in metrics)
- Linkerd — 1 rule (Embedded exporter)
- Istio — 10 rules (Embedded exporter)

### Runtimes

6 services · 35 rules

- PHP-FPM — 1 rule (bakins/php-fpm-exporter)
- JVM — 12 rules (java-client)
- Golang — 10 rules (client_golang)
- Ruby — 5 rules (prometheus_exporter)
- Python — 5 rules (client_python)
- Sidekiq — 2 rules (Strech/sidekiq-prometheus-exporter)

### Data engineering

3 services · 30 rules

- Apache Flink — 12 rules (Built-in Prometheus reporter)
- Apache Spark — 8 rules (Built-in Prometheus (PrometheusServlet + PrometheusResource))
- Hadoop — 10 rules (hadoop/jmx_exporter)

### Orchestrators

5 services · 77 rules

- Kubernetes — 37 rules (kube-state-metrics)
- Nomad — 4 rules (Embedded exporter)
- Consul — 3 rules (prometheus/consul_exporter)
- Etcd — 13 rules (Embedded exporter)
- OpenStack — 20 rules (openstack-exporter/openstack-exporter)

### CI/CD

5 services · 56 rules

- Jenkins — 8 rules (Metric plugin)
- ArgoCD — 2 rules (Embedded exporter)
- FluxCD — 4 rules (Embedded exporter)
- GitLab CI — 30 rules (GitLab built-in exporter · Workhorse · Gitaly)
- Spinnaker — 12 rules (Embedded exporter)

### Network and security

12 services · 70 rules

- SpeedTest — 2 rules (Speedtest exporter)
- SSL/TLS — 4 rules (ssl_exporter)
- cert-manager — 4 rules (Embedded exporter)
- Juniper — 3 rules (czerwonk/junos_exporter)
- CoreDNS — 1 rule (Embedded exporter)
- Freeswitch — 3 rules (znerol/prometheus-freeswitch-exporter)
- Hashicorp Vault — 4 rules (Embedded exporter)
- Keycloak — 6 rules (aerogear/keycloak-metrics-spi)
- Cloudflare — 2 rules (lablabs/cloudflare-exporter)
- SNMP — 7 rules (prometheus/snmp_exporter)
- Cilium — 31 rules (Embedded exporter)
- WireGuard — 3 rules (MindFlavor/prometheus_wireguard_exporter)

### Storage

4 services · 21 rules

- Ceph — 13 rules (Embedded exporter)
- ZFS — 4 rules (node-exporter · ZFS exporter)
- OpenEBS — 1 rule (Embedded exporter)
- Minio — 3 rules (Embedded exporter)

### Cloud providers

4 services · 33 rules

- AWS CloudWatch — 13 rules (prometheus/cloudwatch_exporter)
- Google Cloud Stackdriver — 5 rules (prometheus-community/stackdriver_exporter)
- DigitalOcean — 10 rules (metalmatze/digitalocean_exporter)
- Azure — 5 rules (webdevops/azure-metrics-exporter)

### Observability

9 services · 153 rules

- Thanos — 45 rules (Thanos Compactor · Thanos Query · Thanos Receiver +5)
- Loki — 4 rules (Embedded exporter)
- Promtail — 2 rules (Embedded exporter)
- Cortex — 6 rules (Embedded exporter)
- Grafana Tempo — 18 rules (Embedded exporter)
- Grafana Mimir — 49 rules (Embedded exporter)
- Grafana Alloy — 1 rule (Embedded exporter)
- OpenTelemetry Collector — 12 rules (Embedded exporter)
- Jaeger — 16 rules (Embedded exporter (v2+) · Embedded exporter (legacy, <v2))

### Other

3 services · 15 rules

- APC UPS — 6 rules (mdlayher/apcupsd_exporter)
- Graph Node — 6 rules (Embedded exporter)
- LiteLLM — 3 rules

## Guides

- AlertManager Config — Prometheus and AlertManager configuration examples and troubleshooting.
- Blackbox Exporter — Worldwide probes, Prometheus config, geohash/Grafana map setup.
- Sleep Peacefully — Time-based alert suppression and timezone-aware PromQL patterns.

## Frequently asked questions

**What are Prometheus alerting rules?**

Prometheus alerting rules are PromQL-based conditions evaluated by the Prometheus server. When a condition is true for a specified duration, an alert fires and is routed by AlertManager to receivers like Slack, PagerDuty, or email. Rules are defined as YAML files and cover metrics thresholds, absence of expected data, and rate-of-change conditions.

**How do I use these Prometheus alert rules?**

Find the service you want to monitor, copy the YAML snippet for any rule, and paste it into your Prometheus rules file (e.g., alerts/my-service.yml). Reload Prometheus to apply the rules. Adjust thresholds to match your workload — the values provided are sensible defaults but may need tuning.

**What exporters and services are covered?**

Awesome Prometheus Alerts covers 93 services across 13 categories: Basic resource monitoring, Databases, Message brokers, Proxies/load balancers/service meshes, Runtimes, Data engineering, Orchestrators, CI/CD, Network and security, Storage, Cloud providers, Observability, and Other.

**What is the difference between warning and critical severity?**

Critical alerts require immediate human attention — the system is down or severely degraded and revenue or reliability is directly impacted. Warning alerts need attention soon but are not immediately urgent. Info alerts are awareness-only, such as configuration changes or underutilized resources. Set up AlertManager routes to page on-call engineers only for critical alerts.

**What is PromQL?**

PromQL (Prometheus Query Language) is the functional query language used to select, filter, and aggregate time-series data in Prometheus. Alert rules use PromQL expressions — for example, `rate(http_requests_total[5m]) > 100` fires when request rate exceeds 100/s over a 5-minute window.

**Can I contribute new alert rules?**

Yes! Contributions are welcome. Open a pull request on GitHub at https://github.com/samber/awesome-prometheus-alerts with your new rules added to the _data/rules.yml file. Follow the existing format: provide a clear rule name, a description explaining what the alert means and why it matters, a tested PromQL expression, an appropriate severity, and a sensible "for" duration to avoid false positives.

**What is AlertManager and how does it relate to these rules?**

AlertManager is the component that receives firing alerts from Prometheus and handles deduplication, grouping, silencing, and routing to receivers (Slack, PagerDuty, email, webhooks). The alert rules in this collection fire alerts from Prometheus — AlertManager then decides who to notify and when.

**How do I silence or suppress an alert?**

AlertManager supports silences — time-bounded mutes applied via its UI or API that suppress notifications without disabling the rule. For recurring suppression (nights, weekends, deployments), use inhibition rules or time-based PromQL patterns. See the Sleep Peacefully guide for timezone-aware suppression examples using `day_of_week()` and `hour()` functions.

**What is the license for these alert rules?**

The alert rules and content are licensed under Creative Commons CC BY 4.0 — you are free to use, adapt, and redistribute them, including commercially, as long as you provide attribution. The site source code is licensed under MIT.
