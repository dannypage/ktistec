require "./rule"

module School
  class Rule
    # Rule builder.
    #
    # Used internally to build rules with a DSL.
    #
    class Builder
      @conditions = [] of BasePattern
      @actions = [] of Action

      def initialize(@name : String, *, @trace : Bool = false)
      end

      private def l(m)
        m.is_a?(Expression) ? m : Lit.new(m)
      end

      def condition(f : Fact.class)
        @conditions << NullaryPattern.new(f)
        self
      end

      def condition(f : Fact.class, m)
        @conditions << UnaryPattern.new(f, m)
        self
      end

      def condition(m, f : Fact.class)
        @conditions << UnaryPattern.new(f, m)
        self
      end

      def condition(f : Fact.class, m1, m2)
        @conditions << BinaryPattern.new(f, m1, m2)
        self
      end

      def condition(m1, f : Fact.class, m2)
        @conditions << BinaryPattern.new(f, m1, m2)
        self
      end

      def condition(m1, m2, f : Fact.class)
        @conditions << BinaryPattern.new(f, m1, m2)
        self
      end

      def condition(p : Pattern.class, **options)
        @conditions << p.new(**options)
        self
      end

      def condition(p : Pattern.class, m, **options)
        @conditions << p.new(l(m), **options)
        self
      end

      def condition(m, p : Pattern.class, **options)
        @conditions << p.new(l(m), **options)
        self
      end

      def condition(p : Pattern.class, m1, m2, **options)
        @conditions << p.new(l(m1), l(m2), **options)
        self
      end

      def condition(m1, p : Pattern.class, m2, **options)
        @conditions << p.new(l(m1), l(m2), **options)
        self
      end

      def condition(m1, m2, p : Pattern.class, **options)
        @conditions << p.new(l(m1), l(m2), **options)
        self
      end

      def condition(&block : ProcPattern::ProcType)
        @conditions << ProcPattern.new(block)
        self
      end

      def condition(block : ProcPattern::ProcType)
        @conditions << ProcPattern.new(block)
        self
      end

      def any(f : Fact.class)
        @conditions << Pattern::Any.new(NullaryPattern.new(f))
        self
      end

      def any(f : Fact.class, m)
        @conditions << Pattern::Any.new(UnaryPattern.new(f, m))
        self
      end

      def any(m, f : Fact.class)
        @conditions << Pattern::Any.new(UnaryPattern.new(f, m))
        self
      end

      def any(f : Fact.class, m1, m2)
        @conditions << Pattern::Any.new(BinaryPattern.new(f, m1, m2))
        self
      end

      def any(m1, f : Fact.class, m2)
        @conditions << Pattern::Any.new(BinaryPattern.new(f, m1, m2))
        self
      end

      def any(m1, m2, f : Fact.class)
        @conditions << Pattern::Any.new(BinaryPattern.new(f, m1, m2))
        self
      end

      def any(p : Pattern.class, **options)
        @conditions << Pattern::Any.new(p.new(**options))
        self
      end

      def any(p : Pattern.class, m, **options)
        @conditions << Pattern::Any.new(p.new(l(m), **options))
        self
      end

      def any(m, p : Pattern.class, **options)
        @conditions << Pattern::Any.new(p.new(l(m), **options))
        self
      end

      def any(p : Pattern.class, m1, m2, **options)
        @conditions << Pattern::Any.new(p.new(l(m1), l(m2), **options))
        self
      end

      def any(m1, p : Pattern.class, m2, **options)
        @conditions << Pattern::Any.new(p.new(l(m1), l(m2), **options))
        self
      end

      def any(m1, m2, p : Pattern.class, **options)
        @conditions << Pattern::Any.new(p.new(l(m1), l(m2), **options))
        self
      end

      def any(&block : ProcPattern::ProcType)
        @conditions << Pattern::Any.new(ProcPattern.new(block))
        self
      end

      def any(block : ProcPattern::ProcType)
        @conditions << Pattern::Any.new(ProcPattern.new(block))
        self
      end

      def none(f : Fact.class)
        @conditions << Pattern::None.new(NullaryPattern.new(f))
        self
      end

      def none(f : Fact.class, m)
        @conditions << Pattern::None.new(UnaryPattern.new(f, m))
        self
      end

      def none(m, f : Fact.class)
        @conditions << Pattern::None.new(UnaryPattern.new(f, m))
        self
      end

      def none(f : Fact.class, m1, m2)
        @conditions << Pattern::None.new(BinaryPattern.new(f, m1, m2))
        self
      end

      def none(m1, f : Fact.class, m2)
        @conditions << Pattern::None.new(BinaryPattern.new(f, m1, m2))
        self
      end

      def none(m1, m2, f : Fact.class)
        @conditions << Pattern::None.new(BinaryPattern.new(f, m1, m2))
        self
      end

      def none(p : Pattern.class, **options)
        @conditions << Pattern::None.new(p.new(**options))
        self
      end

      def none(p : Pattern.class, m, **options)
        @conditions << Pattern::None.new(p.new(l(m), **options))
        self
      end

      def none(m, p : Pattern.class, **options)
        @conditions << Pattern::None.new(p.new(l(m), **options))
        self
      end

      def none(p : Pattern.class, m1, m2, **options)
        @conditions << Pattern::None.new(p.new(l(m1), l(m2), **options))
        self
      end

      def none(m1, p : Pattern.class, m2, **options)
        @conditions << Pattern::None.new(p.new(l(m1), l(m2), **options))
        self
      end

      def none(m1, m2, p : Pattern.class, **options)
        @conditions << Pattern::None.new(p.new(l(m1), l(m2), **options))
        self
      end

      def none(&block : ProcPattern::ProcType)
        @conditions << Pattern::None.new(ProcPattern.new(block))
        self
      end

      def none(block : ProcPattern::ProcType)
        @conditions << Pattern::None.new(ProcPattern.new(block))
        self
      end

      # For the following, assert through patterns because patterns
      # can handle expressions and bound values.

      def assert(f : Fact.class)
        @actions << Action.new { |rule, bindings| typeof(NullaryPattern.new(f)).assert(bindings) }
        self
      end

      def assert(f : Fact.class, m)
        @actions << Action.new { |rule, bindings| typeof(UnaryPattern.new(f, m)).assert(m, bindings) }
        self
      end

      def assert(m, f : Fact.class)
        @actions << Action.new { |rule, bindings| typeof(UnaryPattern.new(f, m)).assert(m, bindings) }
        self
      end

      def assert(f : Fact.class, m1, m2)
        @actions << Action.new { |rule, bindings| typeof(BinaryPattern.new(f, m1, m2)).assert(m1, m2, bindings) }
        self
      end

      def assert(m1, f : Fact.class, m2)
        @actions << Action.new { |rule, bindings| typeof(BinaryPattern.new(f, m1, m2)).assert(m1, m2, bindings) }
        self
      end

      def assert(m1, m2, f : Fact.class)
        @actions << Action.new { |rule, bindings| typeof(BinaryPattern.new(f, m1, m2)).assert(m1, m2, bindings) }
        self
      end

      def assert(p : Pattern.class, **options)
        @actions << Action.new { |rule, bindings| p.assert(bindings, **options) }
        self
      end

      def assert(p : Pattern.class, m, **options)
        @actions << Action.new { |rule, bindings| p.assert(m, bindings, **options) }
        self
      end

      def assert(m, p : Pattern.class, **options)
        @actions << Action.new { |rule, bindings| p.assert(m, bindings, **options) }
        self
      end

      def assert(p : Pattern.class, m1, m2, **options)
        @actions << Action.new { |rule, bindings| p.assert(m1, m2, bindings, **options) }
        self
      end

      def assert(m1, p : Pattern.class, m2, **options)
        @actions << Action.new { |rule, bindings| p.assert(m1, m2, bindings, **options) }
        self
      end

      def assert(m1, m2, p : Pattern.class, **options)
        @actions << Action.new { |rule, bindings| p.assert(m1, m2, bindings, **options) }
        self
      end

      def retract(f : Fact.class)
        @actions << Action.new { |rule, bindings| typeof(NullaryPattern.new(f)).retract(bindings) }
        self
      end

      def retract(f : Fact.class, m)
        @actions << Action.new { |rule, bindings| typeof(UnaryPattern.new(f, m)).retract(m, bindings) }
        self
      end

      def retract(m, f : Fact.class)
        @actions << Action.new { |rule, bindings| typeof(UnaryPattern.new(f, m)).retract(m, bindings) }
        self
      end

      def retract(f : Fact.class, m1, m2)
        @actions << Action.new { |rule, bindings| typeof(BinaryPattern.new(f, m1, m2)).retract(m1, m2, bindings) }
        self
      end

      def retract(m1, f : Fact.class, m2)
        @actions << Action.new { |rule, bindings| typeof(BinaryPattern.new(f, m1, m2)).retract(m1, m2, bindings) }
        self
      end

      def retract(m1, m2, f : Fact.class)
        @actions << Action.new { |rule, bindings| typeof(BinaryPattern.new(f, m1, m2)).retract(m1, m2, bindings) }
        self
      end

      def retract(p : Pattern.class, **options)
        @actions << Action.new { |rule, bindings| p.retract(bindings, **options) }
        self
      end

      def retract(p : Pattern.class, m, **options)
        @actions << Action.new { |rule, bindings| p.retract(m, bindings, **options) }
        self
      end

      def retract(m, p : Pattern.class, **options)
        @actions << Action.new { |rule, bindings| p.retract(m, bindings, **options) }
        self
      end

      def retract(p : Pattern.class, m1, m2, **options)
        @actions << Action.new { |rule, bindings| p.retract(m1, m2, bindings, **options) }
        self
      end

      def retract(m1, p : Pattern.class, m2, **options)
        @actions << Action.new { |rule, bindings| p.retract(m1, m2, bindings, **options) }
        self
      end

      def retract(m1, m2, p : Pattern.class, **options)
        @actions << Action.new { |rule, bindings| p.retract(m1, m2, bindings, **options) }
        self
      end

      def action(&action : Action)
        @actions << action
        self
      end

      def action(action : Action)
        @actions << action
        self
      end

      @vars = Hash(String, Var).new { |h, k| h[k] = Var.new(k) }

      # Returns a new variable.
      #
      def var(name : String)
        @vars[name]
      end

      # Returns a not expression.
      #
      def not(any)
        Not.new(any)
      end

      def within(*any)
        Within.new(*any)
      end

      # Builds the rule.
      #
      # Every invocation returns the same rule (it is built once and
      # memoized).
      #
      def build
        @rule ||= Rule.new(@name, @conditions, @actions, trace: @trace)
      end
    end
  end

  # Presents a DSL for defining rules.
  #
  def self.rule(name, *, trace : Bool = false, &block)
    builder = Rule::Builder.new(name, trace: trace)
    with builder yield
    builder.build
  end
end
