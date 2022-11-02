module School
  # An expression.
  #
  abstract class Expression
    @name : String?

    private NAME = /[a-z][a-zA-Z0-9_-]*/

    # Sets the name of the expression.
    #
    protected def name=(@name)
      raise ArgumentError.new("#{@name.inspect} is not a valid name") unless @name =~ NAME
    end

    # Returns the name of the expression.
    #
    getter! name
  end

  # Include in client classes that participate as domain types.
  #
  module DomainType
  end

  # All supported domain types.
  #
  alias DomainTypes = DomainType | String | Symbol | Float64 | Float32 | Int64 | Int32 | Char | Bool | Nil

  # Bindings.
  #
  alias Bindings = Hash(String, DomainTypes)

  # Result.
  #
  # Holds the result of a match as well as any resulting bindings.
  #
  private record Result, success : Bool, bindings : Bindings? = nil

  # Matcher.
  #
  # An expression that can be explicitly matched against a value.
  #
  module Matcher
    # Matches the expression to a value.
    #
    abstract def match(value : DomainTypes) : Result

    # Binds the value into a result.
    #
    protected def bind(value : DomainTypes, result : Result? = nil) : Result
      if result && (temporary = result.bindings)
        name? ?
          Result.new(true, temporary.merge(Bindings{name => value})) :
          Result.new(true, temporary)
      else
        name? ?
          Result.new(true, Bindings{name => value}) :
          Result.new(true)
      end
    end

    protected def no_match
      Result.new(false)
    end
  end

  # An accessor.
  #
  # Wraps a method call or other operation, implemented as a block.
  #
  class Accessor < Expression
    def initialize(&@block : Bindings -> DomainTypes?)
    end

    # Calls the block, passing in the current bindings.
    #
    def call(bindings : Bindings) : DomainTypes?
      @block.call(bindings)
    end
  end

  # A literal.
  #
  class Lit < Expression
    include Matcher

    getter target

    def initialize(@target : DomainTypes, name : String? = nil)
      self.name = name if name
    end

    # :inherit:
    def match(value : DomainTypes) : Result
      value == @target ? bind(value) : no_match
    end

    # :inherit:
    def ==(other : self)
      self.target == other.target
    end

    # Generates an accessor that performs the method call on the
    # literal value.
    #
    macro method_missing(call)
      Accessor.new do |bindings|
        if (t = target).responds_to?({{call.name.symbolize}})
          t.{{call.name.id}}
        else
          raise ArgumentError.new("#{target.class} does not respond to {{call.name}}")
        end
      end
    end
  end

  # A variable.
  #
  class Var < Expression
    include Matcher

    def initialize(name : String)
      self.name = name
    end

    # :inherit:
    def match(value : DomainTypes) : Result
      bind(value)
    end

    # :inherit:
    def ==(other : self)
      self.name == other.name
    end

    # Generates an accessor that performs the method call on the
    # bound value.
    #
    macro method_missing(call)
      Accessor.new do |bindings|
        if (t = bindings[name]) && t.responds_to?({{call.name.symbolize}})
          t.{{call.name.id}}
        else
          raise ArgumentError.new("#{target.class} does not respond to {{call.name}}")
        end
      end
    end
  end

  # A "not" expression.
  #
  class Not < Expression
    include Matcher

    getter target

    def initialize(@target : Matcher, name : String? = nil)
      self.name = name if name
    end

    def initialize(target : DomainTypes, name : String? = nil)
      initialize(Lit.new(target), name: name)
    end

    # :inherit:
    def ==(other : self)
      self.target == other.target
    end

    # :inherit:
    def match(value : DomainTypes) : Result
      result = @target.match(value)
      !result.success ? bind(value, result) : no_match
    end
  end

  # A "within" expression.
  #
  class Within < Expression
    include Matcher

    getter targets

    def initialize(*targets : Lit | Var, name : String? = nil)
      @targets = Array(Lit | Var).new
      targets.each { |target| @targets << target }
      self.name = name if name
    end

    def initialize(*targets : DomainTypes, name : String? = nil)
      @targets = Array(Lit | Var).new
      targets.each { |target| @targets << Lit.new(target) }
      self.name = name if name
    end

    # :inherit:
    def ==(other : self)
      self.targets == other.targets
    end

    # :inherit:
    def match(value : DomainTypes) : Result
      @targets.each do |target|
        result = target.as(Matcher).match(value)
        return bind(value, result) if result.success
      end
      no_match
    end
  end
end
