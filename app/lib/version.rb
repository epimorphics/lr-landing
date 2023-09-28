# frozen_string_literal: true

module Version
  MAJOR = 1
  MINOR = 7
  REVISION = 3
  SUFFIX = 1
  VERSION = "#{MAJOR}.#{MINOR}.#{REVISION}#{SUFFIX && ".#{SUFFIX}"}"
end
