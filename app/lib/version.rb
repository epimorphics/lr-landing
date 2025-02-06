# frozen_string_literal: true

module Version
  MAJOR = 2
  MINOR = 0
  REVISION = 4
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{REVISION}#{SUFFIX && ".#{SUFFIX}"}"
end
