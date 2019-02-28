require "../spec_helper"

describe Spectator::Expectations::Expectation do
  describe "#satisifed?" do
    context "with a successful match" do
      it "is true" do
        value = 42
        match_data = new_matcher(value).match(new_partial(value))
        match_data.matched?.should be_true # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.satisfied?.should be_true
      end

      context "when negated" do
        it "is false" do
          value = 42
          match_data = new_matcher(value).match(new_partial(value))
          match_data.matched?.should be_true # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.satisfied?.should be_false
        end
      end
    end

    context "with an unsuccessful match" do
      it "is false" do
        match_data = new_matcher(42).match(new_partial(777))
        match_data.matched?.should be_false # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.satisfied?.should be_false
      end

      context "when negated" do
        it "is true" do
          match_data = new_matcher(42).match(new_partial(777))
          match_data.matched?.should be_false # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.satisfied?.should be_true
        end
      end
    end
  end

  describe "#values" do
    it "is the same as the match data values" do
      value = 42
      match_data = new_matcher(value).match(new_partial(value))
      expectation = Spectator::Expectations::Expectation.new(match_data, false)
      expectation.values.should eq(match_data.values)
    end
  end

  describe "#actual_message" do
    context "with a successful match" do
      it "equals the matcher's #message" do
        value = 42
        match_data = new_matcher(value).match(new_partial(value))
        match_data.matched?.should be_true # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.actual_message.should eq(match_data.message)
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          value = 42
          match_data = new_matcher(value).match(new_partial(value))
          match_data.matched?.should be_true # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.actual_message.should eq(match_data.negated_message)
        end
      end
    end

    context "with an unsuccessful match" do
      it "equals the matcher's #negated_message" do
        match_data = new_matcher(42).match(new_partial(777))
        match_data.matched?.should be_false # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.actual_message.should eq(match_data.negated_message)
      end

      context "when negated" do
        it "equals the matcher's #message" do
          match_data = new_matcher(42).match(new_partial(777))
          match_data.matched?.should be_false # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.actual_message.should eq(match_data.message)
        end
      end
    end
  end

  describe "#expected_message" do
    context "with a successful match" do
      it "equals the matcher's #message" do
        value = 42
        match_data = new_matcher(value).match(new_partial(value))
        match_data.matched?.should be_true # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.expected_message.should eq(match_data.message)
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          value = 42
          match_data = new_matcher(value).match(new_partial(value))
          match_data.matched?.should be_true # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.expected_message.should eq(match_data.negated_message)
        end
      end
    end

    context "with an unsuccessful match" do
      it "equals the matcher's #message" do
        match_data = new_matcher(42).match(new_partial(777))
        match_data.matched?.should be_false # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.expected_message.should eq(match_data.message)
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          match_data = new_matcher(42).match(new_partial(777))
          match_data.matched?.should be_false # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.expected_message.should eq(match_data.negated_message)
        end
      end
    end
  end
end
