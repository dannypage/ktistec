require "./domain"
require "../rule/builder"

module School
  class Domain
    # Domain builder.
    #
    # Used internally to build a domain with a DSL.
    #
    class Builder
      @facts = Set(Fact).new
      @rules = Set(Rule).new

      def fact(f : Fact.class)
        @facts << f.new
        self
      end

      def fact(f : Fact.class, m)
        @facts << f.new(m)
        self
      end

      def fact(m, f : Fact.class)
        @facts << f.new(m)
        self
      end

      def fact(f : Fact.class, m1, m2)
        @facts << f.new(m1, m2)
        self
      end

      def fact(m1, f : Fact.class, m2)
        @facts << f.new(m1, m2)
        self
      end

      def fact(m1, m2, f : Fact.class)
        @facts << f.new(m1, m2)
        self
      end

      def rule(name, *, trace : Bool = false, &block)
        builder = Rule::Builder.new(name, trace: trace)
        with builder yield
        @rules << builder.build
        self
      end

      def rule(rule : Rule)
        @rules << rule
        self
      end

      # Builds the domain.
      #
      def build
        @facts.each { |fact| Fact.assert(fact) }
        Domain.new(@rules)
      end
    end
  end

  # Presents a DSL for defining domains.
  #
  def self.domain(&block)
    builder = Domain::Builder.new
    with builder yield
    builder.build
  end
end
