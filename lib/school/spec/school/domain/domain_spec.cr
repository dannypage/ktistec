require "../../spec_helper"
require "../../../src/school/domain"
require "../../../src/school/rule/builder"

Spectator.describe School::Domain do
  before_each { School::Fact.clear! }

  describe ".new" do
    it "instantiates a new domain" do
      expect(described_class.new).to be_a(School::Domain)
    end
  end

  subject { described_class.new }

  let(fact) { MockFact.new }

  describe "#facts" do
    it "returns the facts in the domain" do
      expect(subject.facts).to be_a(Enumerable(School::Fact))
    end

    it "is empty" do
      expect(subject.facts).to be_empty
    end
  end

  describe "#assert" do
    it "adds a fact to the domain" do
      expect{subject.assert(fact)}.to change{subject.facts}
      expect(subject.facts).to have(fact)
    end

    context "if a fact is already asserted" do
      before_each { subject.assert(fact) }

      it "raises an error" do
        expect{subject.assert(fact)}.to raise_error(ArgumentError)
      end
    end
  end

  describe "#retract" do
    it "raises an error" do
      expect{subject.retract(fact)}.to raise_error(ArgumentError)
    end

    context "if a fact is already asserted" do
      before_each { subject.assert(fact) }

      it "removes the fact from the domain" do
        expect{subject.retract(fact)}.to change{subject.facts}
        expect(subject.facts).not_to have(fact)
      end
    end
  end

  let(rule) { MockRule.new("") }

  describe "#rules" do
    it "returns the rules in the domain" do
      expect(subject.rules).to be_a(Enumerable(School::Rule))
    end

    it "is empty" do
      expect(subject.rules).to be_empty
    end
  end

  describe "#add" do
    it "adds a rule to the domain" do
      expect{subject.add(rule)}.to change{subject.rules}
      expect(subject.rules).to have(rule)
    end

    context "if a rule is already added" do
      before_each { subject.add(rule) }

      it "does not add the rule to the domain" do
        expect{subject.add(rule)}.not_to change{subject.rules}
      end
    end
  end

  describe "#remove" do
    before_each { subject.add(rule) }

    it "removes a rule from the domain" do
      expect{subject.remove(rule)}.to change{subject.rules}
      expect(subject.rules).not_to have(rule)
    end

    context "if a rule is already removed" do
      before_each { subject.remove(rule) }

      it "raises an error" do
        expect{subject.remove(rule)}.to raise_error(ArgumentError)
      end
    end
  end

  describe "#run" do
    let(output) { [] of School::DomainTypes }

    let(action) do
      School::Action.new do |rule, bindings|
        terms = ["#{rule.name}:"]
        terms += bindings.map { |k, v| "#{k}=#{v}" }
        output << terms.join(" ")
      end
    end

    let(fact) { MockFact.new }

    let(rule) { MockRule.new("rule n", [] of School::BasePattern, [action]) }

    it "does not invoke an action" do
      expect{subject.run}.not_to change{output.dup}
    end

    it "returns no matches status" do
      expect(subject.run).to eq(School::Domain::Status::NoMatches)
    end

    context "when an earlier rule's action asserts a fact that activates a later rule" do
      before_each do
        subject.add(
          School.rule "rule 1" do
            action { subject.assert(fact) }
          end
        )
        subject.add(
          School.rule "rule 2" do
            condition MockFact
            action action
          end
        )
      end

      it "invokes the action" do
        expect{subject.run}.to change{output.dup}.to([
          "rule 2:"
        ])
      end

      it "returns completed status" do
        expect(subject.run).to eq(School::Domain::Status::Completed)
      end
    end

    context "when a later rule's action asserts a fact that activates an earlier rule" do
      before_each do
        subject.add(
          School.rule "rule 1" do
            condition MockFact
            action action
          end
        )
        subject.add(
          School.rule "rule 2" do
            action { subject.assert(fact) }
          end
        )
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      it "returns completed status" do
        expect(subject.run).to eq(School::Domain::Status::Completed)
      end
    end

    context "when an earlier rule's action retracts a fact that activates a later rule" do
      before_each do
        subject.add(
          School.rule "rule 1" do
            action { subject.retract(fact) }
          end
        )
        subject.add(
          School.rule "rule 2" do
            condition MockFact
            action action
          end
        )
        subject.assert(fact)
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      it "returns completed status" do
        expect(subject.run).to eq(School::Domain::Status::Completed)
      end
    end

    context "when a later rule's action retracts a fact that activates an earlier rule" do
      before_each do
        subject.add(
          School.rule "rule 1" do
            condition MockFact
            action action
          end
        )
        subject.add(
          School.rule "rule 2" do
            action { subject.retract(fact) }
          end
        )
        subject.assert(fact)
      end

      it "invokes the action" do
        expect{subject.run}.to change{output.dup}.to([
          "rule 1:"
        ])
      end

      it "returns completed status" do
        expect(subject.run).to eq(School::Domain::Status::Completed)
      end
    end

    context "when a rule action adds a rule" do
      before_each do
        subject.add(
          School.rule "rule 1" do
            action { subject.add(rule) }
          end
        )
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      it "returns completed status" do
        expect(subject.run).to eq(School::Domain::Status::Completed)
      end
    end

    context "when a rule action removes a rule" do
      before_each do
        subject.add(
          School.rule "rule 1" do
            action { subject.remove(rule) }
          end
        )
        subject.add(rule)
      end

      it "invokes the action" do
        expect{subject.run}.to change{output.dup}.to([
          "rule n:"
        ])
      end

      it "returns completed status" do
        expect(subject.run).to eq(School::Domain::Status::Completed)
      end
    end

    context "given a simple rule" do
      before_each do
        subject.add(
          School.rule "rule" do
            condition MockRelationship, "foo", "bar"
            action action
          end
        )
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      context "and a matching fact" do
        before_each do
          subject.assert(MockRelationship.new("foo", "bar"))
        end

        it "invokes the action" do
          expect{subject.run}.to change{output.dup}.to([
            "rule:"
          ])
        end
      end

      context "and a non-matching fact" do
        before_each do
          subject.assert(MockRelationship.new("bar", "foo"))
        end

        it "does not invoke the action" do
          expect{subject.run}.not_to change{output.dup}
        end
      end
    end

    context "given a simple rule with one var" do
      before_each do
        subject.add(
          School.rule "rule" do
            condition MockRelationship, "foo", var("value")
            action action
          end
        )
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      context "and a matching fact" do
        before_each do
          subject.assert(MockRelationship.new("foo", "123"))
        end

        it "invokes the action" do
          expect{subject.run}.to change{output.dup}.to([
            "rule: value=123"
          ])
        end
      end

      context "and a non-matching fact" do
        before_each do
          subject.assert(MockRelationship.new("bar", "123"))
        end

        it "does not invoke the action" do
          expect{subject.run}.not_to change{output.dup}
        end
      end

      context "and multiple matching facts" do
        before_each do
          subject.assert(MockRelationship.new("foo", "123"))
          subject.assert(MockRelationship.new("foo", "abc"))
        end

        it "invokes the action for each match" do
          expect{subject.run}.to change{output.dup}.to([
            "rule: value=123",
            "rule: value=abc"
          ])
        end
      end

      context "and multiple non-matching facts" do
        before_each do
          subject.assert(MockRelationship.new("bar", "123"))
          subject.assert(MockRelationship.new("bar", "abc"))
        end

        it "does not invoke the action" do
          expect{subject.run}.not_to change{output.dup}
        end
      end
    end

    context "given a simple rule with two constrained vars" do
      before_each do
        subject.add(
          School.rule "rule" do
            condition MockRelationship, var("value"), var("value")
            action action
          end
        )
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      context "and a matching fact" do
        before_each do
          subject.assert(MockRelationship.new("foo", "foo"))
        end

        it "invokes the action" do
          expect{subject.run}.to change{output.dup}.to([
            "rule: value=foo"
          ])
        end
      end

      context "and a non-matching fact" do
        before_each do
          subject.assert(MockRelationship.new("bar", "123"))
        end

        it "does not invoke the action" do
          expect{subject.run}.not_to change{output.dup}
        end
      end
    end

    context "given a simple rule with two vars" do
      before_each do
        subject.add(
          School.rule "rule" do
            condition MockRelationship, var("value1"), var("value2")
            action action
          end
        )
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      context "and a matching fact" do
        before_each do
          subject.assert(MockRelationship.new("foo", "bar"))
        end

        it "invokes the action" do
          expect{subject.run}.to change{output.dup}.to([
            "rule: value1=foo value2=bar"
          ])
        end
      end

      context "and a non-matching fact" do
        before_each do
          subject.assert(MockFact.new)
        end

        it "does not invoke the action" do
          expect{subject.run}.not_to change{output.dup}
        end
      end
    end

    context "given a complex rule with two vars" do
      before_each do
        subject.add(
          School.rule "rule" do
            condition MockRelationship, var("value1"), "bar"
            condition MockRelationship, "foo", var("value2")
            action action
          end
        )
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      context "and a matching fact" do
        before_each do
          subject.assert(MockRelationship.new("foo", "bar"))
        end

        it "invokes the action" do
          expect{subject.run}.to change{output.dup}.to([
            "rule: value1=foo value2=bar"
          ])
        end
      end

      context "and a non-matching fact" do
        before_each do
          subject.assert(MockRelationship.new("bar", "foo"))
        end

        it "does not invoke the action" do
          expect{subject.run}.not_to change{output.dup}
        end
      end
    end

    context "beware of under-constrained conditions" do
      before_each do
        subject.add(
          School.rule "rule" do
            condition MockProperty, var("value1")
            condition MockProperty, var("value2")
            action action
          end
        )
      end

      it "does not invoke the action" do
        expect{subject.run}.not_to change{output.dup}
      end

      context "and a matching fact" do
        before_each do
          subject.assert(MockProperty.new(123))
        end

        it "invokes the action" do
          expect{subject.run}.to change{output.dup}.to([
            "rule: value1=123 value2=123"
          ])
        end
      end

      context "and multiple matching facts" do
        before_each do
          subject.assert(MockProperty.new(123))
          subject.assert(MockProperty.new(890))
        end

        it "invokes the action for each match" do
          expect{subject.run}.to change{output.dup}.to([
            "rule: value1=123 value2=123",
            "rule: value1=123 value2=890",
            "rule: value1=890 value2=123",
            "rule: value1=890 value2=890"
          ])
        end
      end
    end

    context "when a rule has no conditions" do
      before_each do
        subject.add(
          School.rule "rule" do
            action action
          end
        )
      end

      it "invokes the action" do
        expect{subject.run}.to change{output.dup}.to([
          "rule:"
        ])
      end
    end

    context "with keyword `any`" do
      context "given a simple rule" do
        before_each do
          subject.add(
            School.rule "rule" do
              any MockRelationship, "foo", "bar"
              action action
            end
          )
        end

        it "does not invoke the action if no facts exist" do
          expect{subject.run}.not_to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "bar"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("bar", "foo"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end
      end

      context "given a simple rule with one var" do
        before_each do
          subject.add(
            School.rule "rule" do
              any MockRelationship, "foo", var("value")
              action action
            end
          )
        end

        it "does not invoke the action if no facts exist" do
          expect{subject.run}.not_to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "123"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("bar", "123"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and multiple matching facts" do
          before_each do
            subject.assert(MockRelationship.new("foo", "123"))
            subject.assert(MockRelationship.new("foo", "abc"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and multiple non-matching facts" do
          before_each do
            subject.assert(MockRelationship.new("bar", "123"))
            subject.assert(MockRelationship.new("bar", "abc"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end
      end

      context "given a simple rule with two constrained vars" do
        before_each do
          subject.add(
            School.rule "rule" do
              any MockRelationship, var("value"), var("value")
              action action
            end
          )
        end

        it "does not invoke the action if no facts exist" do
          expect{subject.run}.not_to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "foo"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "bar"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("bar", "foo"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end
      end

      context "given a simple rule with two vars" do
        before_each do
          subject.add(
            School.rule "rule" do
              any MockRelationship, var("value1"), var("value2")
              action action
            end
          )
        end

        it "does not invoke the action if no facts exist" do
          expect{subject.run}.not_to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "bar"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockFact.new)
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end
      end

      context "given a complex rule with two vars" do
        before_each do
          subject.add(
            School.rule "rule" do
              any MockRelationship, var("value1"), "bar"
              any MockRelationship, "foo", var("value2")
              action action
            end
          )
        end

        it "does not invoke the action if no facts exist" do
          expect{subject.run}.not_to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "bar"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("bar", "foo"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end
      end

      context "given a complex rule with two constrained vars" do
        before_each do
          subject.add(
            School.rule "rule" do
              any MockRelationship, var("value"), "one"
              any MockRelationship, var("value"), "two"
              action action
            end
          )
        end

        it "does not invoke the action if no facts exist" do
          expect{subject.run}.not_to change{output.dup}
        end

        context "and matching facts" do
          before_each do
            subject.assert(MockRelationship.new("foo", "one"))
            subject.assert(MockRelationship.new("foo", "two"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and one matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "one"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and one matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "two"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and two independently matching facts" do
          before_each do
            subject.assert(MockRelationship.new("bar", "one"))
            subject.assert(MockRelationship.new("baz", "two"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end
      end

      context "given a complex rule" do
        before_each do
          subject.add(
            School.rule "rule" do
              any MockProperty, 123
              any MockProperty, 890
              action action
            end
          )
        end

        it "does not invoke the action if no facts exist" do
          expect{subject.run}.not_to change{output.dup}
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockProperty.new(444))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and multiple non-matching facts" do
          before_each do
            subject.assert(MockProperty.new(555))
            subject.assert(MockProperty.new(666))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end
      end
    end

    context "with keyword `none`" do
      context "given a simple rule" do
        before_each do
          subject.add(
            School.rule "rule" do
              none MockRelationship, "foo", "bar"
              action action
            end
          )
        end

        it "invokes the action if no facts exist" do
          expect{subject.run}.to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "bar"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("bar", "foo"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end
      end

      context "given a simple rule with one var" do
        before_each do
          subject.add(
            School.rule "rule" do
              none MockRelationship, "foo", var("value")
              action action
            end
          )
        end

        it "invokes the action if no facts exist" do
          expect{subject.run}.to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "123"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("bar", "123"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and multiple matching facts" do
          before_each do
            subject.assert(MockRelationship.new("foo", "123"))
            subject.assert(MockRelationship.new("foo", "abc"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and multiple non-matching facts" do
          before_each do
            subject.assert(MockRelationship.new("bar", "123"))
            subject.assert(MockRelationship.new("bar", "abc"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end
      end

      context "given a simple rule with two constrained vars" do
        before_each do
          subject.add(
            School.rule "rule" do
              none MockRelationship, var("value"), var("value")
              action action
            end
          )
        end

        it "invokes the action if no facts exist" do
          expect{subject.run}.to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "foo"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "bar"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("bar", "foo"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end
      end

      context "given a simple rule with two vars" do
        before_each do
          subject.add(
            School.rule "rule" do
              none MockRelationship, var("value1"), var("value2")
              action action
            end
          )
        end

        it "invokes the action if no facts exist" do
          expect{subject.run}.to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "bar"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockFact.new)
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end
      end

      context "given a complex rule with two vars" do
        before_each do
          subject.add(
            School.rule "rule" do
              none MockRelationship, var("value1"), "bar"
              none MockRelationship, "foo", var("value2")
              action action
            end
          )
        end

        it "invokes the action if no facts exist" do
          expect{subject.run}.to change{output.dup}
        end

        context "and a matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "bar"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockRelationship.new("bar", "foo"))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end
      end

      context "given a complex rule with two constrained vars" do
        before_each do
          subject.add(
            School.rule "rule" do
              none MockRelationship, var("value"), "one"
              none MockRelationship, var("value"), "two"
              action action
            end
          )
        end

        it "invokes the action if no facts exist" do
          expect{subject.run}.to change{output.dup}
        end

        context "and matching facts" do
          before_each do
            subject.assert(MockRelationship.new("foo", "one"))
            subject.assert(MockRelationship.new("foo", "two"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and one matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "one"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and one matching fact" do
          before_each do
            subject.assert(MockRelationship.new("foo", "two"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end

        context "and two independently matching facts" do
          before_each do
            subject.assert(MockRelationship.new("bar", "one"))
            subject.assert(MockRelationship.new("baz", "two"))
          end

          it "does not invoke the action" do
            expect{subject.run}.not_to change{output.dup}
          end
        end
      end

      context "given a complex rule" do
        before_each do
          subject.add(
            School.rule "rule" do
              none MockProperty, 123
              none MockProperty, 890
              action action
            end
          )
        end

        it "invokes the action if no facts exist" do
          expect{subject.run}.to change{output.dup}
        end

        context "and a non-matching fact" do
          before_each do
            subject.assert(MockProperty.new(444))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end

        context "and multiple non-matching facts" do
          before_each do
            subject.assert(MockProperty.new(555))
            subject.assert(MockProperty.new(666))
          end

          it "invokes the action" do
            expect{subject.run}.to change{output.dup}.to([
              "rule:"
            ])
          end
        end
      end
    end
  end
end
