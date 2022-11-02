require "spectator"
require "yaml"

macro finished
  {% if School.has_constant? "Fact" %}
    class MockFact < School::Fact
    end

    class MockProperty < School::Property(Int32)
    end

    class MockRelationship < School::Relationship(String, String)
    end
  {% end %}

  {% if School.has_constant? "Rule" %}
    class MockRule < School::Rule
    end
  {% end %}
end
