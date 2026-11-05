# frozen_string_literal: true

# Serves the SPARQL query console: the <epi-qonsole> web component from
# @epimorphics/qonsole, configured from config/qonsole.json
class QonsoleController < ApplicationController
  CONFIG_FILE = Rails.root.join('config/qonsole.json')

  def index
    @qonsole_config = self.class.qonsole_config
  end

  # The endpoints, prefixes and example queries the component is given. Read
  # once, as the file only changes with a deploy
  def self.qonsole_config
    @qonsole_config ||= JSON.parse(File.read(CONFIG_FILE))
                            .slice('endpoints', 'prefixes', 'queries')
                            .freeze
  end
end
