require "../../spec_helper"
require "../../../src/school/rule"
require "../../../src/school/rule/builder"

Spectator.describe School::Rule do
  describe ".new" do
    it "instantiates a new rule" do
      expect(School::Rule.new("")).to be_a(School::Rule)
    end
  end

  describe "#vars" do
    subject do
      School.rule "" do
        condition var("a"), MockRelationship, var("b")
        condition var("b"), MockRelationship, var("a")
      end
    end

    it "returns the vars" do
      expect(subject.vars).to contain_exactly("a", "b")
    end
  end

  describe "#call" do
    subject do
      School.rule "" do
        condition var("a"), MockRelationship, var("b")
        action { |rule, bindings| output.concat(bindings.keys) }
        action { |rule, bindings| output.concat(bindings.values) }
      end
    end

    let(bindings) { School::Bindings{"a" => "A", "b" => "B"} }

    let(output) { [] of School::DomainTypes }

    it "invokes the actions" do
      expect{subject.call(bindings)}.to change{output.dup}.to(["a", "b", "A", "B"])
    end
  end
end
