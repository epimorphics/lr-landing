# frozen_string_literal: true

module Version
  MAJOR = 2
  MINOR = 1
  REVISION = 0
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{REVISION}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
