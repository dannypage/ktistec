require "../../spec_helper"
require "../../../src/school/rule/expression"

Spectator.describe School::Lit do
  describe "#==" do
    let(lit) { described_class.new("lit") }

    it "returns true when they are equal" do
      other = described_class.new("lit")
      expect(lit == other).to be_true
    end

    it "returns false when they are not equal" do
      other = described_class.new("other")
      expect(lit == other).to be_false
    end
  end

  describe "#match" do
    let(lit) { described_class.new("lit") }

    it "returns true if the value matches" do
      expect(lit.match("lit").success).to be_true
    end

    it "returns false if the value does not match" do
      expect(lit.match("mus").success).to be_false
    end

    context "nested in a not" do
      subject { School::Not.new(lit) }

      it "returns false if the value matches" do
        expect(subject.match("lit").success).to be_false
      end
    end

    context "nested in a within" do
      subject { School::Within.new(lit) }

      it "returns true if the value matches" do
        expect(subject.match("lit").success).to be_true
      end
    end

    context "given a name" do
      subject { described_class.new("lit", name: "val") }

      it "returns the bindings" do
        expect(subject.match("lit").bindings).to eq(School::Bindings{"val" => "lit"})
      end
    end

    context "with an accessor" do
      it "returns an accessor" do
        expect(lit.size).to be_a(School::Accessor)
      end

      let(bindings) { School::Bindings.new }

      it "calls the named method" do
        expect(lit.size.call(bindings)).to eq(3)
      end

      it "raises an error" do
        expect{lit.foobar.call(bindings)}.to raise_error(ArgumentError)
      end
    end
  end
end

Spectator.describe School::Var do
  describe ".new" do
    it "raises an error if the name is not valid" do
      expect{described_class.new("")}.to raise_error(ArgumentError)
    end
  end

  describe "#==" do
    let(var) { described_class.new("var") }

    it "returns true when they are equal" do
      other = described_class.new("var")
      expect(var == other).to be_true
    end

    it "returns false when they are not equal" do
      other = described_class.new("other")
      expect(var == other).to be_false
    end
  end

  describe "#match" do
    let(var) { described_class.new("var") }

    it "returns the bindings" do
      expect(var.match("value").bindings).to eq(School::Bindings{"var" => "value"})
    end

    context "nested in a not" do
      subject { School::Not.new(var) }

      it "does not return the bindings" do
        expect(subject.match("value").bindings).to be_nil
      end
    end

    context "nested in a within" do
      subject { School::Within.new(var) }

      it "returns the bindings" do
        expect(subject.match("value").bindings).to eq(School::Bindings{"var" => "value"})
      end
    end

    context "with an accessor" do
      it "returns an accessor" do
        expect(var.size).to be_a(School::Accessor)
      end

      let(bindings) { School::Bindings{"var" => "value"} }

      it "calls the named method" do
        expect(var.size.call(bindings)).to eq(5)
      end

      it "raises an error" do
        expect{var.foobar.call(bindings)}.to raise_error(ArgumentError)
      end
    end
  end
end

Spectator.describe School::Not do
  describe "#==" do
    subject { described_class.new("var") }

    it "returns true when they are equal" do
      other = described_class.new("var")
      expect(subject == other).to be_true
    end

    it "returns false when they are not equal" do
      other = described_class.new("other")
      expect(subject == other).to be_false
    end
  end

  describe "#match" do
    subject { described_class.new("target") }

    it "returns true if the value does not match" do
      expect(subject.match("value").success).to be_true
    end

    it "returns false if the value matches" do
      expect(subject.match("target").success).to be_false
    end

    context "given a nested not" do
      subject { described_class.new(described_class.new("target")) }

      it "returns true if the value matches" do
        expect(subject.match("target").success).to be_true
      end

      it "returns false if the value does not match" do
        expect(subject.match("value").success).to be_false
      end
    end

    context "given a nested lit" do
      subject { described_class.new(School::Lit.new("lit")) }

      it "returns false" do
        expect(subject.match("value").success).to be_true
      end
    end

    context "given a nested var" do
      subject { described_class.new(School::Var.new("var")) }

      it "returns false" do
        expect(subject.match("value").success).to be_false
      end
    end

    context "given a name" do
      subject { described_class.new("target", name: "val") }

      it "returns the bindings" do
        expect(subject.match("value").bindings).to eq(School::Bindings{"val" => "value"})
      end
    end
  end
end

Spectator.describe School::Within do
  describe "#==" do
    subject { described_class.new("foo", "bar") }

    it "returns true when they are equal" do
      other = described_class.new("foo", "bar")
      expect(subject == other).to be_true
    end

    it "returns false when they are not equal" do
      other = described_class.new("other")
      expect(subject == other).to be_false
    end
  end

  describe "#match" do
    subject { described_class.new("foo", "bar") }

    it "returns true if the value is within the set" do
      expect(subject.match("bar").success).to be_true
    end

    it "returns false if the value is not within the set" do
      expect(subject.match("baz").success).to be_false
    end

    context "given a nested lit" do
      subject { described_class.new(School::Lit.new("lit")) }

      it "returns true" do
        expect(subject.match("lit").success).to be_true
      end
    end

    context "given a nested var" do
      subject { described_class.new(School::Var.new("var")) }

      it "returns true" do
        expect(subject.match("baz").success).to be_true
      end
    end

    context "given a name" do
      subject { described_class.new("foo", "bar", name: "val") }

      it "returns the bindings" do
        expect(subject.match("foo").bindings).to eq(School::Bindings{"val" => "foo"})
      end
    end
  end
end

Spectator.describe School::Accessor do
  describe "#call" do
    subject do
      described_class.new do |bindings|
        42
      end
    end

    it "calls the block" do
      expect(subject.call(School::Bindings.new)).to eq(42)
    end
  end
end
