# frozen-string-literal: true

# Simple controller for serving documentation
class DocController < ApplicationController
  def ukhpi_dsd
    send_file 'app/views/doc/ukhpi-dsd.ttl', type: 'text/turtle'
  end

  def ukhpi_user_guide
    send_file(
      'app/views/doc/ukhpi-user-guide.pdf',
      type: 'application/pdf',
      disposition: :inline
    )
  end
end
