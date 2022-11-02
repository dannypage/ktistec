# The School rules engine.
#
module School
  # :nodoc:
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end

require "./school/domain"
