# frozen_string_literal: true

module Version
  MAJOR = 2
  MINOR = 0
  REVISION = 2
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{REVISION}#{SUFFIX && ".#{SUFFIX}"}"
end
