# frozen_string_literal: true

prometheus = Prometheus::Client.registry

# Prometheus counters
prometheus.counter(
  :internal_application_error,
  docstring: 'Responses with status 500, labelled by exception class and action',
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

# Middleware instrumentation
# This fixes the 0 memory bug by notifying Action Dispatch subscribers on Prometheus initialise
ActiveSupport::Notifications.instrument('process_middleware.action_dispatch')
