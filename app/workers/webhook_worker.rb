require 'http.rb'

class WebhookWorker
  include Sidekiq::Worker

  def perform(webhook_event_id)
    webhook_event = WebhookEvent.find_by(id: webhook_event_id)
    return if
      webhook_event.nil?
  
    webhook_listener = webhook_event.webhook_listener
    return if
    webhook_listener.nil?
  
    # Send the webhook request.
    response = HTTP.timeout(30)
                   .headers(
                     'User-Agent' => 'rails_webhook_system/1.0',
                     'Content-Type' => 'application/json',
                   )
                   .post(
                    webhook_listener.url,
                     body: {
                       event: webhook_event.event,
                       payload: webhook_event.payload,
                     }.to_json
                   )
  
    # Store the webhook response.
    webhook_event.update(response: {
      headers: response.headers.to_h,
      code: response.code.to_i,
      body: response.body.to_s,
    })
  
    # Raise a failed request error.
    raise FailedRequestError unless
      response.status.success?
  rescue HTTP::TimeoutError
    webhook_event.update(response: { error: 'TIMEOUT_ERROR' })
  end
  

  private
  
  class FailedRequestError < StandardError; end
end
