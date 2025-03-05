# frozen_string_literal: true

module Version
  MAJOR = 2
  MINOR = 0
  REVISION = 5
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{REVISION}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
