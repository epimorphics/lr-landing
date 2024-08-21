# frozen_string_literal: true

# Subscribe to :data_api events
class ApiPrometheusSubscriber < ActiveSupport::Subscriber
  attach_to :api

  def response(event)
    response = event.payload[:response]
    duration = event.payload[:duration]

    Prometheus::Client.registry
                      .get(:api_status)
                      .increment(labels: { status: response.status.to_s })

    Prometheus::Client.registry
                      .get(:api_requests)
                      .increment(labels: { result: 'success' })

    Prometheus::Client.registry
                      .get(:api_response_times)
                      .observe(duration)
  end

  def connection_failure(event)
    exception = event.payload[:exception]
    message = exception.message || exception.to_s

    Prometheus::Client.registry
                      .get(:api_requests)
                      .increment(labels: { result: 'failure' })

    Prometheus::Client.registry
                      .get(:api_connection_failure)
                      .increment(labels: { message: })
  end

  def service_exception(event)
    exception = event.payload[:exception]
    status = exception_status(exception)

    return if status == 404

    Prometheus::Client.registry
                      .get(:api_service_exception)
                      .increment(labels: { status: })
  end

  private

  def exception_status(exception)
    status = 500

    begin
      json = JSON.parse(exception.message)
      status = json['status'] if json&.key?('status')
    rescue JSON::ParserError
      # was not JSON after all
    end

    status = exception.status if exception.respond_to?(:status)

    status
  end
end
