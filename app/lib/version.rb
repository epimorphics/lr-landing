# frozen_string_literal: true

module Version
  MAJOR = 1
  MINOR = 7
  REVISION = 1
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{REVISION}#{SUFFIX && ".#{SUFFIX}"}"
end
