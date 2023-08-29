class CreateWebhookEndpoints < ActiveRecord::Migration[6.1]
  def change
    create_table :webhook_listener do |t|
      t.string :url, null: false

      t.timestamps
    end
  end
end
