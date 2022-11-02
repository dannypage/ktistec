require "../../spec_helper"
require "../../../src/school/rule/builder"

Spectator.describe School::Rule::Builder do
  describe ".new" do
    it "builds a rule" do
      expect(described_class.new("").build).to be_a(School::Rule)
    end

    it "builds a rule with a name" do
      expect(described_class.new("name").build.name).to eq("name")
    end
  end

  let(subject) { described_class.new("") }

  describe "#condition" do
    # nullary condition

    it "adds a condition to the rule" do
      expect{subject.condition(MockFact)}.to change{subject.build.conditions.size}
    end

    it "adds a nullary condition to the rule" do
      expect(subject.condition(MockFact).build.conditions.first).to be_a(School::NullaryPattern(MockFact))
    end

    it "adds a condition to the rule" do
      expect{subject.condition(School::NullaryPattern(MockFact))}.to change{subject.build.conditions.size}
    end

    it "adds a nullary condition to the rule" do
      expect(subject.condition(School::NullaryPattern(MockFact)).build.conditions.first).to be_a(School::NullaryPattern(MockFact))
    end

    # unary condition, first argument

    it "adds a condition to the rule" do
      expect{subject.condition(MockProperty, 0)}.to change{subject.build.conditions.size}
    end

    it "adds a unary condition to the rule" do
      expect(subject.condition(MockProperty, 0).build.conditions.first).to be_a(School::UnaryPattern(MockProperty, Int32))
    end

    it "adds a condition to the rule" do
      expect{subject.condition(School::UnaryPattern(MockProperty, School::Lit), 0)}.to change{subject.build.conditions.size}
    end

    it "adds a unary condition to the rule" do
      expect(subject.condition(School::UnaryPattern(MockProperty, School::Lit), 0).build.conditions.first).to be_a(School::UnaryPattern(MockProperty, School::Lit))
    end

    # unary condition, second argument

    it "adds a condition to the rule" do
      expect{subject.condition(0, MockProperty)}.to change{subject.build.conditions.size}
    end

    it "adds a unary condition to the rule" do
      expect(subject.condition(0, MockProperty).build.conditions.first).to be_a(School::UnaryPattern(MockProperty, Int32))
    end

    it "adds a condition to the rule" do
      expect{subject.condition(0, School::UnaryPattern(MockProperty, School::Lit))}.to change{subject.build.conditions.size}
    end

    it "adds a unary condition to the rule" do
      expect(subject.condition(0, School::UnaryPattern(MockProperty, School::Lit)).build.conditions.first).to be_a(School::UnaryPattern(MockProperty, School::Lit))
    end

    # binary condition, first argument

    it "adds a condition to the rule" do
      expect{subject.condition(MockRelationship, "a", "b")}.to change{subject.build.conditions.size}
    end

    it "adds a binary condition to the rule" do
      expect(subject.condition(MockRelationship, "a", "b").build.conditions.first).to be_a(School::BinaryPattern(MockRelationship, String, String))
    end

    it "adds a condition to the rule" do
      expect{subject.condition(School::BinaryPattern(MockRelationship, School::Lit, School::Lit), "a", "b")}.to change{subject.build.conditions.size}
    end

    it "adds a binary condition to the rule" do
      expect(subject.condition(School::BinaryPattern(MockRelationship, School::Lit, School::Lit), "a", "b").build.conditions.first).to be_a(School::BinaryPattern(MockRelationship, School::Lit, School::Lit))
    end

    # binary condition, second argument

    it "adds a condition to the rule" do
      expect{subject.condition("a", MockRelationship, "b")}.to change{subject.build.conditions.size}
    end

    it "adds a binary condition to the rule" do
      expect(subject.condition("a", MockRelationship, "b").build.conditions.first).to be_a(School::BinaryPattern(MockRelationship, String, String))
    end

    it "adds a condition to the rule" do
      expect{subject.condition("a", School::BinaryPattern(MockRelationship, School::Lit, School::Lit), "b")}.to change{subject.build.conditions.size}
    end

    it "adds a binary condition to the rule" do
      expect(subject.condition("a", School::BinaryPattern(MockRelationship, School::Lit, School::Lit), "b").build.conditions.first).to be_a(School::BinaryPattern(MockRelationship, School::Lit, School::Lit))
    end

    # binary condition, third argument

    it "adds a condition to the rule" do
      expect{subject.condition("a", "b", MockRelationship)}.to change{subject.build.conditions.size}
    end

    it "adds a binary condition to the rule" do
      expect(subject.condition("a", "b", MockRelationship).build.conditions.first).to be_a(School::BinaryPattern(MockRelationship, String, String))
    end

    it "adds a condition to the rule" do
      expect{subject.condition("a", "b", School::BinaryPattern(MockRelationship, School::Lit, School::Lit))}.to change{subject.build.conditions.size}
    end

    it "adds a binary condition to the rule" do
      expect(subject.condition("a", "b", School::BinaryPattern(MockRelationship, School::Lit, School::Lit)).build.conditions.first).to be_a(School::BinaryPattern(MockRelationship, School::Lit, School::Lit))
    end

    # given a block

    it "adds a condition to the rule" do
      expect{subject.condition {}}.to change{subject.build.conditions.size}
    end

    it "adds a proc pattern to the rule" do
      expect(subject.condition {}.build.conditions.first).to be_a(School::ProcPattern)
    end

    # given a proc

    it "adds a condition to the rule" do
      expect{subject.condition(School::ProcPattern::ProcType.new {})}.to change{subject.build.conditions.size}
    end

    it "adds a proc pattern to the rule" do
      expect(subject.condition(School::ProcPattern::ProcType.new {}).build.conditions.first).to be_a(School::ProcPattern)
    end
  end

  describe "#any" do
    # nullary condition

    it "adds a condition to the rule" do
      expect{subject.any(MockFact)}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.any(School::NullaryPattern(MockFact))}.to change{subject.build.conditions.size}
    end

    # unary condition, first argument

    it "adds a condition to the rule" do
      expect{subject.any(MockProperty, 0)}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.any(School::UnaryPattern(MockProperty, School::Lit), 0)}.to change{subject.build.conditions.size}
    end

    # unary condition, second argument

    it "adds a condition to the rule" do
      expect{subject.any(0, MockProperty)}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.any(0, School::UnaryPattern(MockProperty, School::Lit))}.to change{subject.build.conditions.size}
    end

    # binary condition, first argument

    it "adds a condition to the rule" do
      expect{subject.any(MockRelationship, "a", "b")}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.any(School::BinaryPattern(MockRelationship, School::Lit, School::Lit), "a", "b")}.to change{subject.build.conditions.size}
    end

    # binary condition, second argument

    it "adds a condition to the rule" do
      expect{subject.any("a", MockRelationship, "b")}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.any("a", School::BinaryPattern(MockRelationship, School::Lit, School::Lit), "b")}.to change{subject.build.conditions.size}
    end

    # binary condition, third argument

    it "adds a condition to the rule" do
      expect{subject.any("a", "b", MockRelationship)}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.any("a", "b", School::BinaryPattern(MockRelationship, School::Lit, School::Lit))}.to change{subject.build.conditions.size}
    end

    # given a block

    it "adds a condition to the rule" do
      expect{subject.any {}}.to change{subject.build.conditions.size}
    end

    # given a proc

    it "adds a condition to the rule" do
      expect{subject.any(School::ProcPattern::ProcType.new {})}.to change{subject.build.conditions.size}
    end
  end

  describe "#none" do
    # nullary condition

    it "adds a condition to the rule" do
      expect{subject.none(MockFact)}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.none(School::NullaryPattern(MockFact))}.to change{subject.build.conditions.size}
    end

    # unary condition, first argument

    it "adds a condition to the rule" do
      expect{subject.none(MockProperty, 0)}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.none(School::UnaryPattern(MockProperty, School::Lit), 0)}.to change{subject.build.conditions.size}
    end

    # unary condition, second argument

    it "adds a condition to the rule" do
      expect{subject.none(0, MockProperty)}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.none(0, School::UnaryPattern(MockProperty, School::Lit))}.to change{subject.build.conditions.size}
    end

    # binary condition, first argument

    it "adds a condition to the rule" do
      expect{subject.none(MockRelationship, "a", "b")}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.none(School::BinaryPattern(MockRelationship, School::Lit, School::Lit), "a", "b")}.to change{subject.build.conditions.size}
    end

    # binary condition, second argument

    it "adds a condition to the rule" do
      expect{subject.none("a", MockRelationship, "b")}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.none("a", School::BinaryPattern(MockRelationship, School::Lit, School::Lit), "b")}.to change{subject.build.conditions.size}
    end

    # binary condition, third argument

    it "adds a condition to the rule" do
      expect{subject.none("a", "b", MockRelationship)}.to change{subject.build.conditions.size}
    end

    it "adds a condition to the rule" do
      expect{subject.none("a", "b", School::BinaryPattern(MockRelationship, School::Lit, School::Lit))}.to change{subject.build.conditions.size}
    end

    # given a block

    it "adds a condition to the rule" do
      expect{subject.none {}}.to change{subject.build.conditions.size}
    end

    # given a proc

    it "adds a condition to the rule" do
      expect{subject.none(School::ProcPattern::ProcType.new {})}.to change{subject.build.conditions.size}
    end
  end

  describe "#assert" do
    let(rule) { School::Rule.new("") }
    let(bindings) { School::Bindings.new }

    # nullary assertion

    context "given a fact" do
      before_each { School::Fact.clear! }

      it "adds an action to the rule" do
        expect{subject.assert(MockFact)}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(MockFact).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockFact.new)
      end

      it "adds an action to the rule" do
        expect{subject.assert(School::NullaryPattern(MockFact))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::NullaryPattern(MockFact)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockFact.new)
      end
    end

    # unary assertion, first argument

    context "given a property" do
      before_each { School::Fact.clear! }

      it "adds an action to the rule" do
        expect{subject.assert(MockProperty, School::Lit.new(123))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(MockProperty, School::Lit.new(123)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockProperty.new(123))
      end

      it "adds an action to the rule" do
        expect{subject.assert(School::UnaryPattern(MockProperty, Int32), School::Lit.new(123))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::UnaryPattern(MockProperty, Int32), School::Lit.new(123)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockProperty.new(123))
      end
    end

    # unary assertion, second argument

    context "given a property" do
      before_each { School::Fact.clear! }

      it "adds an action to the rule" do
        expect{subject.assert(School::Lit.new(123), MockProperty)}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::Lit.new(123), MockProperty).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockProperty.new(123))
      end

      it "adds an action to the rule" do
        expect{subject.assert(School::Lit.new(123), School::UnaryPattern(MockProperty, Int32))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::Lit.new(123), School::UnaryPattern(MockProperty, Int32)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockProperty.new(123))
      end
    end

    # binary assertion, first argument

    context "given a relationship" do
      before_each { School::Fact.clear! }

      it "adds an action to the rule" do
        expect{subject.assert(MockRelationship, School::Lit.new("abc"), School::Lit.new("xyz"))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(MockRelationship, School::Lit.new("abc"), School::Lit.new("xyz")).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockRelationship.new("abc", "xyz"))
      end

      it "adds an action to the rule" do
        expect{subject.assert(School::BinaryPattern(MockRelationship, String, String), School::Lit.new("abc"), School::Lit.new("xyz"))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::BinaryPattern(MockRelationship, String, String), School::Lit.new("abc"), School::Lit.new("xyz")).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockRelationship.new("abc", "xyz"))
      end
    end

    # binary assertion, second argument

    context "given a relationship" do
      before_each { School::Fact.clear! }

      it "adds an action to the rule" do
        expect{subject.assert(School::Lit.new("abc"), MockRelationship, School::Lit.new("xyz"))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::Lit.new("abc"), MockRelationship, School::Lit.new("xyz")).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockRelationship.new("abc", "xyz"))
      end

      it "adds an action to the rule" do
        expect{subject.assert(School::Lit.new("abc"), School::BinaryPattern(MockRelationship, String, String), School::Lit.new("xyz"))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::Lit.new("abc"), School::BinaryPattern(MockRelationship, String, String), School::Lit.new("xyz")).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockRelationship.new("abc", "xyz"))
      end
    end

    # binary assertion, third argument

    context "given a relationship" do
      before_each { School::Fact.clear! }

      it "adds an action to the rule" do
        expect{subject.assert(School::Lit.new("abc"), School::Lit.new("xyz"), MockRelationship)}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::Lit.new("abc"), School::Lit.new("xyz"), MockRelationship).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockRelationship.new("abc", "xyz"))
      end

      it "adds an action to the rule" do
        expect{subject.assert(School::Lit.new("abc"), School::Lit.new("xyz"), School::BinaryPattern(MockRelationship, String, String))}.to change{subject.build.actions.size}
      end

      it "asserts a fact when the action is called" do
        expect{subject.assert(School::Lit.new("abc"), School::Lit.new("xyz"), School::BinaryPattern(MockRelationship, String, String)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(MockRelationship.new("abc", "xyz"))
      end
    end
  end

  describe "#retract" do
    let(rule) { School::Rule.new("") }
    let(bindings) { School::Bindings.new }

    # nullary retraction

    context "given a fact" do
      before_each { School::Fact.clear! && School::Fact.assert(MockFact.new) }

      it "adds an action to the rule" do
        expect{subject.retract(MockFact)}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(MockFact).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end

      it "adds an action to the rule" do
        expect{subject.retract(School::NullaryPattern(MockFact))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::NullaryPattern(MockFact)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end
    end

    # unary retraction, first argument

    context "given a property" do
      before_each { School::Fact.clear! && School::Fact.assert(MockProperty.new(123)) }

      it "adds an action to the rule" do
        expect{subject.retract(MockProperty, School::Lit.new(123))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(MockProperty, School::Lit.new(123)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end

      it "adds an action to the rule" do
        expect{subject.retract(School::UnaryPattern(MockProperty, Int32), School::Lit.new(123))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::UnaryPattern(MockProperty, Int32), School::Lit.new(123)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end
    end

    # unary retraction, second argument

    context "given a property" do
      before_each { School::Fact.clear! && School::Fact.assert(MockProperty.new(123)) }

      it "adds an action to the rule" do
        expect{subject.retract(School::Lit.new(123), MockProperty)}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::Lit.new(123), MockProperty).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end

      it "adds an action to the rule" do
        expect{subject.retract(School::Lit.new(123), School::UnaryPattern(MockProperty, Int32))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::Lit.new(123), School::UnaryPattern(MockProperty, Int32)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end
    end

    # binary retraction, first argument

    context "given a relationship" do
      before_each { School::Fact.clear! && School::Fact.assert(MockRelationship.new("abc", "xyz")) }

      it "adds an action to the rule" do
        expect{subject.retract(MockRelationship, School::Lit.new("abc"), School::Lit.new("xyz"))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(MockRelationship, School::Lit.new("abc"), School::Lit.new("xyz")).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end

      it "adds an action to the rule" do
        expect{subject.retract(School::BinaryPattern(MockRelationship, String, String), School::Lit.new("abc"), School::Lit.new("xyz"))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::BinaryPattern(MockRelationship, String, String), School::Lit.new("abc"), School::Lit.new("xyz")).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end
    end

    # binary retraction, second argument

    context "given a relationship" do
      before_each { School::Fact.clear! && School::Fact.assert(MockRelationship.new("abc", "xyz")) }

      it "adds an action to the rule" do
        expect{subject.retract(School::Lit.new("abc"), MockRelationship, School::Lit.new("xyz"))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::Lit.new("abc"), MockRelationship, School::Lit.new("xyz")).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end

      it "adds an action to the rule" do
        expect{subject.retract(School::Lit.new("abc"), School::BinaryPattern(MockRelationship, String, String), School::Lit.new("xyz"))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::Lit.new("abc"), School::BinaryPattern(MockRelationship, String, String), School::Lit.new("xyz")).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end
    end

    # binary retraction, third argument

    context "given a relationship" do
      before_each { School::Fact.clear! && School::Fact.assert(MockRelationship.new("abc", "xyz")) }

      it "adds an action to the rule" do
        expect{subject.retract(School::Lit.new("abc"), School::Lit.new("xyz"), MockRelationship)}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::Lit.new("abc"), School::Lit.new("xyz"), MockRelationship).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end

      it "adds an action to the rule" do
        expect{subject.retract(School::Lit.new("abc"), School::Lit.new("xyz"), School::BinaryPattern(MockRelationship, String, String))}.to change{subject.build.actions.size}
      end

      it "retracts a fact when the action is called" do
        expect{subject.retract(School::Lit.new("abc"), School::Lit.new("xyz"), School::BinaryPattern(MockRelationship, String, String)).build.actions.first.call(rule, bindings)}.to change{School::Fact.facts.first?}.to(nil)
      end
    end
  end

  describe "#action" do
    # given a block

    it "adds an action to the rule" do
      expect{subject.action {}}.to change{subject.build.actions.size}
    end

    it "adds an action to the rule" do
      expect(subject.action {}.build.actions.first).to be_a(School::Action)
    end

    # given a block with arguments

    it "adds an action to the rule" do
      expect{subject.action { |r, b| }}.to change{subject.build.actions.size}
    end

    it "adds an action to the rule" do
      expect(subject.action { |r, b| }.build.actions.first).to be_a(School::Action)
    end

    # given a proc

    it "adds an action to the rule" do
      expect{subject.action(->(r : School::Rule, b : School::Bindings) {})}.to change{subject.build.actions.size}
    end

    it "adds an action to the rule" do
      expect(subject.action(->(r : School::Rule, b : School::Bindings) {}).build.actions.first).to be_a(School::Action)
    end
  end

  describe "#var" do
    it "allocates a new var" do
      expect(subject.var("i")).to be_a(School::Var)
    end
  end

  describe "#not" do
    it "allocates a new expression" do
      expect(subject.not("target")).to be_a(School::Not)
    end
  end

  describe "#within" do
    it "allocates a new expression" do
      expect(subject.within("target")).to be_a(School::Within)
    end
  end
end

Spectator.describe School do
  describe ".rule" do
    it "builds a new rule" do
      expect(described_class.rule "rule" { condition MockFact }).to be_a(School::Rule)
    end
  end
end
