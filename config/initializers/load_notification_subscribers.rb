  # frozen_string_literal: true

  # Load all the notification subscribers in the application so that they are registered
  Dir[Rails.root.join('app', 'subscribers', '**', '*_subscriber.rb')].sort.each do |source|
    require source
  end
