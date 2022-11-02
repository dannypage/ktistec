require "../../spec_helper"
require "../../../src/school/domain/builder"

Spectator.describe School::Domain::Builder do
  before_each { School::Fact.clear! }

  describe ".new" do
    it "builds a domain" do
      expect(described_class.new.build).to be_a(School::Domain)
    end
  end

  let(subject) { described_class.new }

  describe "#fact" do
    # fact

    it "adds a fact to the domain" do
      expect{subject.fact(MockFact)}.to change{subject.build.facts.size}
    end

    it "adds a fact to the domain" do
      expect(subject.fact(MockFact).build.facts.first).to be_a(School::Fact)
    end

    # property, first argument

    it "adds a fact to the domain" do
      expect{subject.fact(MockProperty, 0)}.to change{subject.build.facts.size}
    end

    it "adds a property to the domain" do
      expect(subject.fact(MockProperty, 0).build.facts.first).to be_a(School::Property(Int32))
    end

    # property, second argument

    it "adds a fact to the domain" do
      expect{subject.fact(0, MockProperty)}.to change{subject.build.facts.size}
    end

    it "adds a property to the domain" do
      expect(subject.fact(0, MockProperty).build.facts.first).to be_a(School::Property(Int32))
    end

    # relationship, first argument

    it "adds a fact to the domain" do
      expect{subject.fact(MockRelationship, "a", "b")}.to change{subject.build.facts.size}
    end

    it "adds a relationship to the domain" do
      expect(subject.fact(MockRelationship, "a", "b").build.facts.first).to be_a(School::Relationship(String, String))
    end

    # relationship, second argument

    it "adds a fact to the domain" do
      expect{subject.fact("a", MockRelationship, "b")}.to change{subject.build.facts.size}
    end

    it "adds a relationship to the domain" do
      expect(subject.fact("a", MockRelationship, "b").build.facts.first).to be_a(School::Relationship(String, String))
    end

    # relationship, third argument

    it "adds a fact to the domain" do
      expect{subject.fact("a", "b", MockRelationship)}.to change{subject.build.facts.size}
    end

    it "adds a relationship to the domain" do
      expect(subject.fact("a", "b", MockRelationship).build.facts.first).to be_a(School::Relationship(String, String))
    end
  end

  describe "#rule" do
    # given a block

    it "adds a rule to the domain" do
      expect{subject.rule "rule" {}}.to change{subject.build.rules.size}
    end

    it "adds a rule to the domain" do
      expect(subject.rule "rule" {}.build.rules.first).to be_a(School::Rule)
    end

    # given a rule

    it "adds a rule to the domain" do
      expect{subject.rule(MockRule.new(""))}.to change{subject.build.rules.size}
    end

    it "adds a rule to the domain" do
      expect(subject.rule(MockRule.new("")).build.rules.first).to be_a(School::Rule)
    end
  end
end

Spectator.describe School do
  describe ".domain" do
    it "builds a new domain" do
      expect(described_class.domain { fact MockFact }).to be_a(School::Domain)
    end
  end
end
