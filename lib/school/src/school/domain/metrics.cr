module School
  # Rule engine metrics accumulator.
  #
  class Metrics
    INSTANCE = new

    # Returns the `Metrics` singleton instance.
    #
    def self.instance
      INSTANCE
    end

    getter runs, rules, conditions, operations, start

    # Initializes a new instance.
    #
    private def initialize(*, @runs = 0, @rules = 0, @conditions = 0, @operations = 0, @start = Time.utc)
    end

    # Resets internal state.
    #
    # Parameters for explicitly setting internal state are provided
    # for testing purposes.
    #
    def reset(*, @runs = 0, @rules = 0, @conditions = 0, @operations = 0, @start = Time.utc)
    end

    # Returns the metrics.
    #
    # A parameter for the current time is provided for testing
    # purposes.
    #
    def metrics(*, now = Time.utc)
      {
        runs: runs,
        rules: rules,
        conditions: conditions,
        conditions_per_run: conditions.to_f / runs.to_f,
        conditions_per_rule: conditions.to_f / rules.to_f,
        operations: operations,
        operations_per_run: operations.to_f / runs.to_f,
        operations_per_rule: operations.to_f / rules.to_f,
        runtime: runtime(now: now)
      }
    end

    # Increments runs.
    #
    def count_run
      @runs += 1
    end

    # Increments rules.
    #
    def count_rule
      @rules += 1
    end

    # Increments conditions.
    #
    def count_condition
      @conditions += 1
    end

    # Increments operations.
    #
    def count_operation
      @operations += 1
    end

    # generate singleton methods for public instance methods.

    # methods below this point are not included in singleton methods.

    {% for method in @type.methods.select { |m| m.visibility == :public } %}
      def self.{{method.name}}
        instance.{{method.name}}
      end
    {% end %}

    # Returns the runtime.
    #
    # A parameter for the current time is provided for testing
    # purposes.
    #
    def runtime(*, now = Time.utc)
      now - start
    end
  end
end
