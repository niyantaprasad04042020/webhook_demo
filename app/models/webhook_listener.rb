class WebhookEndpoint < ApplicationRecord
  has_many :webhook_events
  
  validates :url, presence: true
end