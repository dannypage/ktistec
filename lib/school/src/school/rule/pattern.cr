require "./expression"
require "../fact"
require "../utils/trace"

module School
  class TraceNode < Trace
    def condition(pattern : BasePattern)
      @pattern = "Condition #{pattern}"
    end

    @fact : String?

    def fact(fact, before : Bindings, after : Bindings)
      @fact = String::Builder.build do |sb|
        sb << "Match "
        fact.to_s(sb)
        sb << ", bindings: "
        diff_bindings(sb, before, after)
      end.to_s
    end

    def match(bindings : Bindings)
      @fact = String::Builder.build do |sb|
        sb << "Match bindings: ["
        pp_bindings(sb, bindings)
        sb << "]"
      end.to_s
    end

    private def diff_bindings(sb, b, a)
      unless (d = a.reject(b.keys)).empty?
        pp_bindings(sb, d)
        sb << " "
      end
      sb << "["
      pp_bindings(sb, b)
      sb << "]"
    end

    private def pp_bindings(sb, h)
      h.each.with_index do |(k, v), i|
        sb << " " if i > 0
        k.to_s(sb)
        sb << "="
        case v
        when String
          v.inspect(sb)
        else
          v.to_s(sb)
        end
      end
    end

    protected def render(ar = [] of String)
      ar << "  #{@pattern}" if @pattern
      ar << "    #{@fact}" if @fact
    end
  end

  # A pattern.
  #
  # Prefer `Pattern` over `BasePattern` since classes derived from
  # `Pattern` can be used with special patterns `Any` and `None`.
  #
  abstract class BasePattern
    # Returns the variables in the pattern.
    #
    abstract def vars : Enumerable(String)

    # Indicates whether or not any facts match the pattern.
    #
    # Yields once for each match.
    #
    abstract def match(bindings : Bindings, trace : TraceNode? = nil, &block : Bindings -> Nil) : Nil

    # Appends a short `String` representation of this object.
    #
    def to_s(io : IO)
      self.class.to_s(io)
    end
  end

  # A pattern.
  #
  abstract class Pattern < BasePattern
    # A special pattern that indicates a condition that is satisfied
    # if and only if at least one fact matches the wrapped pattern.
    #
    class Any < BasePattern
      def initialize(@pattern : Pattern)
      end

      # :inherit:
      def vars : Enumerable(String)
        @pattern.vars
      end

      # :inherit:
      def match(bindings : Bindings, trace : TraceNode? = nil, &block : Bindings -> Nil) : Nil
        trace.condition(self) if trace
        if @pattern.match(bindings) { break true }
          trace.match(bindings) if trace
          yield bindings
        end
      end

      # :inherit:
      def to_s(io : IO)
        io << "Any "
        @pattern.class.to_s(io)
      end
    end

    # A special pattern that indicates a condition that is satisfied
    # if and only if no facts match the wrapped pattern.
    #
    class None < BasePattern
      def initialize(@pattern : Pattern)
      end

      # :inherit:
      def vars : Enumerable(String)
        @pattern.vars
      end

      # :inherit:
      def match(bindings : Bindings, trace : TraceNode? = nil, &block : Bindings -> Nil) : Nil
        trace.condition(self) if trace
        unless @pattern.match(bindings) { break true }
          trace.match(bindings) if trace
          yield bindings
        end
      end

      # :inherit:
      def to_s(io : IO)
        io << "None "
        @pattern.class.to_s(io)
      end
    end
  end

  # Patterns that match against the `Fact` database.
  #
  abstract class FactPattern < Pattern
    # Indicates whether or not the fact matches the pattern.
    #
    abstract def match(fact : Fact, bindings : Bindings) : Bindings?

    # :inherit:
    def match(bindings : Bindings, trace : TraceNode? = nil, &block : Bindings -> Nil) : Nil
      trace.condition(self) if trace
      Fact.facts.each do |fact|
        if (temporary = match(fact, bindings))
          trace.fact(fact, bindings, temporary) if trace
          yield temporary
        end
      end
    end

    # Matches two values.
    #
    # Returns the updated bindings.
    #
    protected def match_values(pairs, bindings)
      pairs.reduce(bindings) do |bindings, args|
        if bindings
          that, this = args
          if that == this
            bindings
          elsif this.is_a?(Accessor) && that == this.call(bindings)
            bindings
          elsif this.is_a?(Matcher) && (temporary = check_result(this.match(that), bindings))
            temporary
          end
        end
      end
    end

    # Checks the result for binding conflicts.
    #
    # Returns the merged bindings.
    #
    protected def check_result(result, bindings)
      if result.success
        if (temporary = result.bindings)
          if temporary.none? { |k, v| bindings.has_key?(k) && bindings[k] != v }
            bindings.merge(temporary)
          end
        else
          bindings
        end
      end
    end
  end

  # A pattern that matches a fact.
  #
  class NullaryPattern(F) < FactPattern
    def initialize
      initialize(F)
    end

    def initialize(fact_class : F.class)
      {% unless F < Fact && F.ancestors.all?(&.type_vars.empty?) %}
        {% raise "#{F} is not a nullary School::Fact" %}
      {% end %}
    end

    # :inherit:
    def vars : Enumerable(String)
      Set(String).new
    end

    # :inherit:
    def match(fact : Fact, bindings : Bindings) : Bindings?
      if fact.is_a?(F)
        bindings
      end
    end

    # Asserts the associated `Fact`.
    #
    def self.assert(bindings : Bindings)
      Fact.assert(F.new)
    end

    # Retracts the associated `Fact`.
    #
    def self.retract(bindings : Bindings)
      Fact.retract(F.new)
    end
  end

  # A pattern that matches a fact with one argument.
  #
  class UnaryPattern(F, C) < FactPattern
    getter c

    def initialize(c : C)
      initialize(F, c)
    end

    def initialize(fact_class : F.class, @c : C)
      {% begin %}
        {% ancestor = F.ancestors.find { |a| !a.type_vars.empty? } %}
        {% if F < Fact && ancestor && (types = ancestor.type_vars).size == 1 %}
          {% unless C == types[0] || C <= Expression %}
            {% raise "the argument must be #{types[0]} or School::Expression, not #{C}" %}
          {% end %}
        {% else %}
          {% raise "#{F} is not a unary School::Fact" %}
        {% end %}
      {% end %}
    end

    # :inherit:
    def vars : Enumerable(String)
      Set(String).new.tap do |vars|
        if (c = @c).is_a?(Var)
          vars << c.name
        end
      end
    end

    # :inherit:
    def match(fact : Fact, bindings : Bindings) : Bindings?
      if fact.is_a?(F)
        match_values([{fact.c, self.c}], bindings)
      end
    end

    private def self.new_fact(c, bindings)
      if c.is_a?(Lit)
        unless (c = c.target).is_a?(F::C)
          raise ArgumentError.new
        end
      elsif c.is_a?(Var)
        unless (name = c.name?) && (c = bindings[name]?) && c.is_a?(F::C)
          raise ArgumentError.new
        end
      end
      F.new(c)
    end

    # Asserts the associated `Fact`.
    #
    def self.assert(c : F::C | Lit | Var, bindings : Bindings)
      Fact.assert(new_fact(c, bindings))
    end

    # Retracts the associated `Fact`.
    #
    def self.retract(c : F::C | Lit | Var, bindings : Bindings)
      Fact.retract(new_fact(c, bindings))
    end
  end

  # A pattern that matches a fact with two arguments.
  #
  class BinaryPattern(F, A, B) < FactPattern
    getter a, b

    def initialize(a : A, b : B)
      initialize(F, a, b)
    end

    def initialize(fact_class : F.class, @a : A, @b : B)
      {% begin %}
        {% ancestor = F.ancestors.find { |a| !a.type_vars.empty? } %}
        {% if F < Fact && ancestor && (types = ancestor.type_vars).size == 2 %}
          {% unless A == types[0] || A <= Expression %}
            {% raise "the first argument must be #{types[0]} or School::Expression, not #{A}" %}
          {% end %}
          {% unless B == types[1] || B <= Expression %}
            {% raise "the second argument must be #{types[1]} or School::Expression, not #{B}" %}
          {% end %}
        {% else %}
          {% raise "#{F} is not a binary School::Fact" %}
        {% end %}
      {% end %}
    end

    # :inherit:
    def vars : Enumerable(String)
      Set(String).new.tap do |vars|
        if (a = @a).is_a?(Var)
          vars << a.name
        end
        if (b = @b).is_a?(Var)
          vars << b.name
        end
      end
    end

    # :inherit:
    def match(fact : Fact, bindings : Bindings) : Bindings?
      if fact.is_a?(F)
        match_values([{fact.a, self.a}, {fact.b, self.b}], bindings)
      end
    end

    private def self.new_fact(a, b, bindings)
      if a.is_a?(Lit)
        unless (a = a.target).is_a?(F::A)
          raise ArgumentError.new
        end
      elsif a.is_a?(Var)
        unless (name = a.name?) && (a = bindings[name]?) && a.is_a?(F::A)
          raise ArgumentError.new
        end
      end
      if b.is_a?(Lit)
        unless (b = b.target).is_a?(F::B)
          raise ArgumentError.new
        end
      elsif b.is_a?(Var)
        unless (name = b.name?) && (b = bindings[name]?) && b.is_a?(F::B)
          raise ArgumentError.new
        end
      end
      F.new(a, b)
    end

    # Asserts the associated `Fact`.
    #
    def self.assert(a : F::A | Lit | Var, b : F::B | Lit | Var, bindings : Bindings)
      Fact.assert(new_fact(a, b, bindings))
    end

    # Retracts the associated `Fact`.
    #
    def self.retract(a : F::A | Lit | Var, b : F::B | Lit | Var, bindings : Bindings)
      Fact.retract(new_fact(a, b, bindings))
    end
  end

  # A pattern that wraps a proc.
  #
  class ProcPattern < Pattern
    alias ProcType = Proc(Bindings, Bindings | Nil)

    def initialize(@proc : ProcType)
    end

    # :inherit:
    def vars : Enumerable(String)
      [] of String
    end

    # :inherit:
    def match(bindings : Bindings, trace : TraceNode? = nil, &block : Bindings -> Nil) : Nil
      if (temporary = @proc.call(bindings))
        if temporary.none? { |k, v| bindings.has_key?(k) && bindings[k] != v }
          yield bindings.merge(temporary)
        end
      end
    end
  end
end
