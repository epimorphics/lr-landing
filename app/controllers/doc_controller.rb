class DocController < ApplicationController
  def ukhpi_dsd
    send_file "app/views/doc/ukhpi-dsd.ttl", type: "text/turtle"
  end
end
