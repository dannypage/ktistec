require "../../spec_helper"
require "../../../src/school/utils/trace"

class School::TraceRoot < School::Trace
  protected def render(ar = [] of String)
    ar << "ROOT"
  end
end

class School::TraceNode < School::Trace
  protected def render(ar = [] of String)
    ar << "NODE"
  end
end

Spectator.describe School::Trace do
  describe ".root" do
    it "returns an instance of the trace root class" do
      expect(described_class.root).to be_a(School::TraceRoot)
    end
  end
end

Spectator.describe School::TraceRoot do
  subject { School::Trace.root }

  pre_condition { expect(subject).to be_a(School::TraceRoot) }

  describe "#nest" do
    it "returns an instance of the trace node class" do
      expect(subject.nest).to be_a(School::TraceNode)
    end
  end

  describe "#dump" do
    it "renders nothing" do
      str = String.build { |io| subject.dump(io) }
      expect(str).to eq("")
    end
  end
end

Spectator.describe School::TraceNode do
  let(root) { School::Trace.root }

  subject { root.nest }

  pre_condition { expect(subject).to be_a(School::TraceNode) }

  describe "#nest" do
    it "returns an instance of the trace node class" do
      expect(subject.nest).to be_a(School::TraceNode)
    end
  end

  describe "#succeed" do
    it "renders the graph" do
      subject.succeed
      str = String.build { |io| root.dump(io) }
      expect(str).to eq("SUCCESS\nROOT\nNODE\n")
    end
  end

  describe "#fail" do
    it "renders the graph" do
      subject.fail
      str = String.build { |io| root.dump(io) }
      expect(str).to eq("ROOT\nNODE\n    <no match>\n")
    end
  end
end
