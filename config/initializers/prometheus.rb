# frozen_string_literal: true

prometheus = Prometheus::Client.registry

# Prometheus counters
prometheus.counter(
  :api_status,
  docstring: 'Count of API responses, labelled by status',
  labels: [:status]
)

prometheus.counter(
  :api_requests,
  docstring: 'Count of API responses, labelled by succeeded true/false',
  labels: [:result]
)

prometheus.counter(
  :api_connection_failure,
  docstring: 'Total of failures to connect to API, labelled by reason',
  labels: [:message]
)

prometheus.counter(
  :api_service_exception,
  docstring: 'Total of other errors when processing API responses',
  labels: [:status]
)

prometheus.counter(
  :internal_application_error,
  docstring: 'Unexpected events and internal error count',
  labels: [:message]
)

# Prometheus gauges
prometheus.gauge(
  :memory_used_mb,
  docstring: 'Process memory usage in mb'
)

prometheus.gauge(
  :process_threads,
  docstring: 'The number of process threads, labelled by status',
  labels: [:status],
  preset_labels: { status: 'total' }
)

# Histograms

prometheus.histogram(
  :api_response_times,
  docstring: 'Histogram of back-end API response times',
  buckets: Prometheus::Client::Histogram.exponential_buckets(start: 0.0005, count: 16)
)
