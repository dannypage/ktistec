require "./generic_arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ValueMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, location, @value : ReturnType, args = nil)
      super(name, location, args)
    end

    def call(args : GenericArguments(T, NT), & : -> RT) forall T, NT, RT
      @value
    end
  end
end
