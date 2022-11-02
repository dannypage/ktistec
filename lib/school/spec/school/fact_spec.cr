require "../spec_helper"
require "../../src/school/fact"

Spectator.describe School::Fact do
  describe ".new" do
    it "instantiates a new fact" do
      expect(MockFact.new).to be_a(School::Fact)
    end

    it "instantiates a new fact" do
      expect(MockProperty.new(123)).to be_a(School::Fact)
    end

    it "instantiates a new fact" do
      expect(MockRelationship.new("xyz", "abc")).to be_a(School::Fact)
    end
  end

  before_each { School::Fact.clear! }

  describe ".assert" do
    it "asserts a fact" do
      expect(School::Fact.assert(MockFact.new)).to be_a(School::Fact)
      expect(School::Fact.facts).to have(MockFact.new)
    end

    context "if the fact was previously asserted" do
      before_each { School::Fact.assert(MockFact.new) }

      it "raises an error" do
        expect{School::Fact.assert(MockFact.new)}.to raise_error(ArgumentError)
      end
    end
  end

  describe ".retract" do
    it "raises an error" do
      expect{School::Fact.retract(MockFact.new)}.to raise_error(ArgumentError)
    end

    context "if the fact was previously asserted" do
      before_each { School::Fact.assert(MockFact.new) }

      it "retracts the fact" do
        expect(School::Fact.retract(MockFact.new)).to be_a(School::Fact)
        expect(School::Fact.facts).not_to have(MockFact.new)
      end
    end
  end
end
