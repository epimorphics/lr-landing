# frozen_string_literal: true

# Load all the notification subscribers in the application so that they are registered
Rails.root.glob('app/subscribers/**/*_subscriber.rb').each do |source|
  require source
end
