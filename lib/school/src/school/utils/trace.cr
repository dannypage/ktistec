module School
  # Rule evaluation tracing utility class.
  #
  abstract class Trace
    private def initialize
    end

    # Instantiates a trace root.
    #
    def self.root
      TraceRoot.new
    end

    # Renders the node.
    #
    protected def render(ar = [] of String)
      raise "#render method of abstract class called"
    end

    # Yields a nested/chained trace node.
    #
    def nest
      yield nest
    end
  end

  # The root in a trace.
  #
  class TraceRoot < Trace
    protected def initialize
    end

    protected def backtrace(ar = [] of String)
      render(ar)
      ar
    end

    protected getter successes = [] of String

    protected getter failures = [] of String

    # Dumps the trace.
    #
    def dump(io = STDOUT)
      successes.each { |success| io.puts success }
      failures.each { |failure| io.puts failure }
    end

    def nest
      TraceNode.new(self)
    end
  end

  # A node in a trace.
  #
  class TraceNode < Trace
    protected def initialize(@parent : Trace)
    end

    protected def backtrace(ar = [] of String)
      @parent.backtrace(ar)
      render(ar)
      ar
    end

    private def root
      this = self
      while this.is_a?(TraceNode)
        this = this.@parent
      end
      this.as(TraceRoot)
    end

    # Indicates a successful match.
    #
    def succeed
      root.successes << (["SUCCESS"] + backtrace).join("\n")
    end

    # Indicates a failed match.
    #
    def fail
      root.failures << (backtrace + ["    <no match>"]).join("\n")
    end

    def nest
      TraceNode.new(self)
    end
  end
end
