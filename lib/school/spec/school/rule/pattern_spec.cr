require "../../spec_helper"
require "../../../src/school/rule/pattern"

Spectator.describe School::NullaryPattern do
  before_each { School::Fact.clear! }

  describe ".new" do
    it "instantiates a new pattern" do
      expect(School::NullaryPattern(MockFact).new).to be_a(School::Pattern)
    end

    it "instantiates a new pattern" do
      expect(described_class.new(MockFact)).to be_a(School::Pattern)
    end
  end

  describe "#vars" do
    it "returns the vars" do
      expect(described_class.new(MockFact).vars).to be_empty
    end
  end

  describe "#match" do
    let(bindings) { School::Bindings.new }

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockFact).match(MockFact.new, bindings)).to eq(bindings)
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockFact).match(MockProperty.new(123), bindings)).to be_nil
    end
  end

  # test the base class implementation of `match` here

  describe "#match" do
    let(output) { [] of String }

    let(proc) { -> { output << "called" } }

    let(bindings) { School::Bindings.new }

    it "yields once for each match" do
      [MockProperty.new(123), MockFact.new, MockProperty.new(890)].each { |fact| School::Fact.assert(fact) }
      expect{described_class.new(MockFact).match(bindings, &proc)}.to change{output.dup}.to(["called"])
    end
  end

  describe ".assert" do
    before_each { School::Fact.clear! }

    let(bindings) { School::Bindings.new }

    it "asserts the fact" do
      expect{School::NullaryPattern(MockFact).assert(bindings)}.to change{School::Fact.facts.first?}.to(MockFact.new)
    end
  end

  describe ".retract" do
    before_each { School::Fact.clear! && School::Fact.assert(MockFact.new) }

    let(bindings) { School::Bindings.new }

    it "retracts the fact" do
      expect{School::NullaryPattern(MockFact).retract(bindings)}.to change{School::Fact.facts.first?}.to(nil)
    end
  end
end

Spectator.describe School::UnaryPattern do
  describe ".new" do
    it "instantiates a new pattern" do
      expect(School::UnaryPattern(MockProperty, Int32).new(123)).to be_a(School::Pattern)
    end

    it "instantiates a new pattern" do
      expect(described_class.new(MockProperty, 123)).to be_a(School::Pattern)
    end

    it "accepts a var as the argument" do
      expect(described_class.new(MockProperty, School::Var.new("c"))).to be_a(School::Pattern)
    end

    it "compiles" do
      # ensure `expression` is type `School::Expression+`
      expression = (rand > 0.5) ? School::Lit.new("e") : School::Var.new("e")
      expect(described_class.new(MockProperty, expression)).to be_a(School::Pattern)
    end
  end

  describe "#vars" do
    subject { described_class.new(MockProperty, School::Var.new("c")) }

    it "returns the vars" do
      expect(subject.vars).to contain_exactly("c")
    end
  end

  describe "#match" do
    let(fact) { MockProperty.new(123) }
    let(bindings) { School::Bindings{"z" => "zzz"} }

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockProperty, 123).match(fact, bindings)).to eq(bindings)
    end

    it "merges the bindings if the fact matches" do
      expect(described_class.new(MockProperty, School::Var.new("c")).match(fact, bindings)).to eq(School::Bindings{"c" => 123, "z" => "zzz"})
    end

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockProperty, School::Var.new("c")).match(fact, School::Bindings{"c" => 123})).to eq(School::Bindings{"c" => 123})
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockProperty, School::Var.new("c")).match(fact, School::Bindings{"c" => 890})).to be_nil
    end

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockProperty, School::Accessor.new { 123 }).match(fact, bindings)).to eq(bindings)
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockProperty, School::Accessor.new { 890 }).match(fact, bindings)).to be_nil
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockProperty, 123).match(MockProperty.new(890), bindings)).to be_nil
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockProperty, 123).match(MockFact.new, bindings)).to be_nil
    end
  end

  describe ".assert" do
    before_each { School::Fact.clear! }

    let(bindings) { School::Bindings{"c" => 123} }

    it "asserts the fact" do
      expect{School::UnaryPattern(MockProperty, Int32).assert(School::Var.new("c"), bindings)}.to change{School::Fact.facts.first?}.to(MockProperty.new(123))
    end

    it "raises an error if the name is not bound" do
      expect{School::UnaryPattern(MockProperty, Int32).assert(School::Var.new("x"), bindings)}.to raise_error(ArgumentError)
    end

    it "asserts the fact" do
      expect{School::UnaryPattern(MockProperty, Int32).assert(123, bindings)}.to change{School::Fact.facts.first?}.to(MockProperty.new(123))
    end
  end

  describe ".retract" do
    before_each { School::Fact.clear! && School::Fact.assert(MockProperty.new(123)) }

    let(bindings) { School::Bindings{"c" => 123} }

    it "retracts the fact" do
      expect{School::UnaryPattern(MockProperty, Int32).retract(School::Var.new("c"), bindings)}.to change{School::Fact.facts.first?}.to(nil)
    end

    it "raises an error if the name is not bound" do
      expect{School::UnaryPattern(MockProperty, Int32).retract(School::Var.new("x"), bindings)}.to raise_error(ArgumentError)
    end

    it "retracts the fact" do
      expect{School::UnaryPattern(MockProperty, Int32).retract(123, bindings)}.to change{School::Fact.facts.first?}.to(nil)
    end
  end
end

Spectator.describe School::BinaryPattern do
  describe ".new" do
    it "instantiates a new pattern" do
      expect(School::BinaryPattern(MockRelationship, String, String).new("abc", "xyz")).to be_a(School::Pattern)
    end

    it "instantiates a new pattern" do
      expect(described_class.new(MockRelationship, "abc", "xyz")).to be_a(School::Pattern)
    end

    it "accepts a var as the first argument" do
      expect(described_class.new(MockRelationship, School::Var.new("m"), "xyz")).to be_a(School::Pattern)
    end

    it "accepts a var as the second argument" do
      expect(described_class.new(MockRelationship, "abc", School::Var.new("n"))).to be_a(School::Pattern)
    end

    it "compiles" do
      # ensure `expression` is type `School::Expression+`
      expression = (rand > 0.5) ? School::Lit.new("e") : School::Var.new("e")
      expect(described_class.new(MockRelationship, expression, expression)).to be_a(School::Pattern)
    end
  end

  describe "#vars" do
    subject { described_class.new(MockRelationship, School::Var.new("m"), School::Var.new("n")) }

    it "returns the vars" do
      expect(subject.vars).to contain_exactly("m", "n")
    end
  end

  describe "#match" do
    let(fact) { MockRelationship.new("abc", "xyz") }
    let(bindings) { School::Bindings{"z" => "zzz"} }

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, "abc", "xyz").match(fact, bindings)).to eq(bindings)
    end

    it "merges the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, School::Var.new("a"), "xyz").match(fact, bindings)).to eq(School::Bindings{"a" => "abc", "z" => "zzz"})
    end

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, School::Var.new("a"), "xyz").match(fact, School::Bindings{"a" => "abc"})).to eq(School::Bindings{"a" => "abc"})
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, School::Var.new("a"), "xyz").match(fact, School::Bindings{"a" => "zzz"})).to be_nil
    end

    it "merges the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, "abc", School::Var.new("b")).match(fact, bindings)).to eq(School::Bindings{"b" => "xyz", "z" => "zzz"})
    end

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, "abc", School::Var.new("b")).match(fact, School::Bindings{"b" => "xyz"})).to eq(School::Bindings{"b" => "xyz"})
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, "abc", School::Var.new("b")).match(fact, School::Bindings{"b" => "zzz"})).to be_nil
    end

    it "merges the bindings if the facts match" do
      expect(described_class.new(MockRelationship, School::Var.new("a"), School::Var.new("b")).match(fact, bindings)).to eq(School::Bindings{"a" => "abc", "b" => "xyz", "z" => "zzz"})
    end

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, School::Var.new("a"), School::Var.new("b")).match(fact, School::Bindings{"a" => "abc", "b" => "xyz"})).to eq(School::Bindings{"a" => "abc", "b" => "xyz"})
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, School::Var.new("a"), School::Var.new("b")).match(fact, School::Bindings{"a" => "zzz", "b" => "zzz"})).to be_nil
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, School::Var.new("v"), School::Var.new("v")).match(fact, bindings)).to be_nil
    end

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, School::Accessor.new { "abc" }, "xyz").match(fact, bindings)).to eq(bindings)
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, School::Accessor.new { 123 }, "xyz").match(fact, bindings)).to be_nil
    end

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, "abc", School::Accessor.new { "xyz" }).match(fact, bindings)).to eq(bindings)
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, "abc", School::Accessor.new { 123 }).match(fact, bindings)).to be_nil
    end

    it "returns the bindings if the fact matches" do
      expect(described_class.new(MockRelationship, School::Accessor.new { "abc" }, School::Accessor.new { "xyz" }).match(fact, bindings)).to eq(bindings)
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, School::Accessor.new { 123 }, School::Accessor.new { "xyz" }).match(fact, bindings)).to be_nil
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, School::Accessor.new { "abc" }, School::Accessor.new { 123 }).match(fact, bindings)).to be_nil
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, School::Accessor.new { 123 }, School::Accessor.new { 123 }).match(fact, bindings)).to be_nil
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, "abc", "xyz").match(MockRelationship.new("abc", "123"), bindings)).to be_nil
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, "abc", "xyz").match(MockRelationship.new("123", "xyz"), bindings)).to be_nil
    end

    it "returns nil if the fact does not match" do
      expect(described_class.new(MockRelationship, "abc", "xyz").match(MockFact.new, bindings)).to be_nil
    end
  end

  describe ".assert" do
    before_each { School::Fact.clear! }

    let(bindings) { School::Bindings{"a" => "abc", "b" => "xyz"} }

    it "asserts the fact" do
      expect{School::BinaryPattern(MockRelationship, String, String).assert(School::Var.new("a"), School::Var.new("b"), bindings)}.to change{School::Fact.facts.first?}.to(MockRelationship.new("abc", "xyz"))
    end

    it "raises an error if the name is not bound" do
      expect{School::BinaryPattern(MockRelationship, String, String).assert(School::Var.new("x"), School::Var.new("b"), bindings)}.to raise_error(ArgumentError)
    end

    it "raises an error if the name is not bound" do
      expect{School::BinaryPattern(MockRelationship, String, String).assert(School::Var.new("a"), School::Var.new("x"), bindings)}.to raise_error(ArgumentError)
    end

    it "asserts the fact" do
      expect{School::BinaryPattern(MockRelationship, String, String).assert("abc", "xyz", bindings)}.to change{School::Fact.facts.first?}.to(MockRelationship.new("abc", "xyz"))
    end
  end

  describe ".retract" do
    before_each { School::Fact.clear! && School::Fact.assert(MockRelationship.new("abc", "xyz")) }

    let(bindings) { School::Bindings{"a" => "abc", "b" => "xyz"} }

    it "retracts the fact" do
      expect{School::BinaryPattern(MockRelationship, String, String).retract(School::Var.new("a"), School::Var.new("b"), bindings)}.to change{School::Fact.facts.first?}.to(nil)
    end

    it "raises an error if the name is not bound" do
      expect{School::BinaryPattern(MockRelationship, String, String).retract(School::Var.new("x"), School::Var.new("b"), bindings)}.to raise_error(ArgumentError)
    end

    it "raises an error if the name is not bound" do
      expect{School::BinaryPattern(MockRelationship, String, String).retract(School::Var.new("a"), School::Var.new("x"), bindings)}.to raise_error(ArgumentError)
    end

    it "retracts the fact" do
      expect{School::BinaryPattern(MockRelationship, String, String).retract("abc", "xyz", bindings)}.to change{School::Fact.facts.first?}.to(nil)
    end
  end
end

Spectator.describe School::Pattern::Any do
  before_each { School::Fact.clear! }

  describe ".new" do
    it "instantiates a new pattern by wrapping a pattern" do
      expect(described_class.new(School::NullaryPattern.new(MockFact))).to be_a(School::BasePattern)
    end
  end

  describe "#vars" do
    subject { described_class.new(School::BinaryPattern.new(MockRelationship, School::Var.new("m"), School::Var.new("n"))) }

    it "returns the vars in the wrapped pattern" do
      expect(subject.vars).to contain_exactly("m", "n")
    end
  end

  describe "#match" do
    let(output) { [] of String }

    let(proc) { -> { output << "called" } }

    let(bindings) { School::Bindings.new }

    it "yields once if any match" do
      [MockProperty.new(123), MockFact.new, MockProperty.new(890)].each { |fact| School::Fact.assert(fact) }
      expect{described_class.new(School::UnaryPattern.new(MockProperty, 123)).match(bindings, &proc)}.to change{output.dup}.to(["called"])
    end
  end
end

Spectator.describe School::Pattern::None do
  before_each { School::Fact.clear! }

  describe ".new" do
    it "instantiates a new pattern by wrapping a pattern" do
      expect(described_class.new(School::NullaryPattern.new(MockFact))).to be_a(School::BasePattern)
    end
  end

  describe "#vars" do
    subject { described_class.new(School::BinaryPattern.new(MockRelationship, School::Var.new("m"), School::Var.new("n"))) }

    it "returns the vars in the wrapped pattern" do
      expect(subject.vars).to contain_exactly("m", "n")
    end
  end

  describe "#match" do
    let(output) { [] of String }

    let(proc) { -> { output << "called" } }

    let(bindings) { School::Bindings.new }

    it "yields once if none match" do
      [MockProperty.new(123), MockFact.new, MockProperty.new(890)].each { |fact| School::Fact.assert(fact) }
      expect{described_class.new(School::UnaryPattern.new(MockProperty, 456)).match(bindings, &proc)}.to change{output.dup}.to(["called"])
    end
  end
end

Spectator.describe School::ProcPattern do
  describe ".new" do
    it "instantiates a new pattern" do
      proc = School::ProcPattern::ProcType.new {}
      expect(described_class.new(proc)).to be_a(School::Pattern)
    end
  end

  describe "#match" do
    let(output) { [] of School::Bindings }

    let(proc) { -> (bindings : School::Bindings) { output << bindings} }

    let(bindings) { School::Bindings.new }

    it "does not yield if condition returns nil" do
      condition = School::ProcPattern::ProcType.new { nil }
      expect{described_class.new(condition).match(bindings, &proc)}.not_to change{output.dup}
    end

    it "yields if the condition returns bindings" do
      condition = School::ProcPattern::ProcType.new { School::Bindings{"foo" => "bar"} }
      expect{described_class.new(condition).match(bindings, &proc)}.to change{output.dup}.to([School::Bindings{"foo" => "bar"}])
    end

    it "yields and merges bindings if the condition returns bindings" do
      condition = School::ProcPattern::ProcType.new { School::Bindings{"foo" => "bar"} }
      expect{described_class.new(condition).match(School::Bindings{"abc" => "xyz"}, &proc)}.to change{output.dup}.to([School::Bindings{"abc" => "xyz", "foo" => "bar"}])
    end

    it "yields and returns bindings if bindings match" do
      condition = School::ProcPattern::ProcType.new { School::Bindings{"foo" => "bar"} }
      expect{described_class.new(condition).match(School::Bindings{"foo" => "bar"}, &proc)}.to change{output.dup}.to([School::Bindings{"foo" => "bar"}])
    end

    it "does not yield if bindings conflict" do
      condition = School::ProcPattern::ProcType.new { School::Bindings{"foo" => "bar"} }
      expect{described_class.new(condition).match(School::Bindings{"foo" => "baz"}, &proc)}.not_to change{output.dup}
    end
  end
end
