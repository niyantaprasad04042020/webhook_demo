class WebhookEvent < ApplicationRecord
  belongs_to :webhook_listener

  validates :event, presence: true
  validates :payload, presence: true
end