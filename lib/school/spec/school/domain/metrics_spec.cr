require "../../spec_helper"
require "../../../src/school/domain/metrics"

Spectator.describe School::Metrics do
  subject { described_class.instance }

  describe "#count_run" do
    it "increments runs" do
      expect{subject.count_run}.to change{subject.runs}.by(1)
    end
  end

  describe "#count_rule" do
    it "increments rules" do
      expect{subject.count_rule}.to change{subject.rules}.by(1)
    end
  end

  describe "#count_condition" do
    it "increments conditions" do
      expect{subject.count_condition}.to change{subject.conditions}.by(1)
    end
  end

  describe "#count_operation" do
    it "increments operations" do
      expect{subject.count_operation}.to change{subject.operations}.by(1)
    end
  end

  context "given a run" do
    let(start) { Time.utc(2016, 2, 15, 10, 20, 30) }
    let(now) { start + 5.seconds }

    before_each do
      subject.reset(start: start)
      1.times { subject.count_run }
      2.times { subject.count_rule }
      4.times { subject.count_condition }
      6.times { subject.count_operation }
    end

    describe "#runtime" do
      it "returns the runtime" do
        expect(subject.runtime(now: now)).to eq(5.seconds)
      end
    end

    describe "#metrics" do
      let(metrics) { subject.metrics(now: now) }

      it "returns the runs" do
        expect(metrics[:runs]).to eq(1)
      end

      it "returns the rules" do
        expect(metrics[:rules]).to eq(2)
      end

      it "returns the conditions" do
        expect(metrics[:conditions]).to eq(4)
      end

      it "returns the conditions per run" do
        expect(metrics[:conditions_per_run]).to eq(4.0)
      end

      it "returns the conditions per rule" do
        expect(metrics[:conditions_per_rule]).to eq(2.0)
      end

      it "returns the operations" do
        expect(metrics[:operations]).to eq(6)
      end

      it "returns the operations per run" do
        expect(metrics[:operations_per_run]).to eq(6.0)
      end

      it "returns the operations per rule" do
        expect(metrics[:operations_per_rule]).to eq(3.0)
      end

      it "returns the runtime" do
        expect(metrics[:runtime]).to eq(5.seconds)
      end
    end
  end
end
