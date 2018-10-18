require "../spec_helper"

describe Spectator::Matchers::EqualityMatcher do
  describe "#match?" do
    it "compares using #==" do
      spy = SpySUT.new
      partial = Spectator::Expectations::ValueExpectationPartial.new("", spy)
      matcher = Spectator::Matchers::EqualityMatcher.new("", 42)
      matcher.match?(partial).should be_true
      spy.eq_call_count.should be > 0
    end

    context "with identical values" do
      it "is true" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
        matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
        matcher.match?(partial).should be_true
      end
    end

    context "with different values" do
      it "is false" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1.to_s, value1)
        matcher = Spectator::Matchers::EqualityMatcher.new(value2.to_s, value2)
        matcher.match?(partial).should be_false
      end
    end

    context "with the same instance" do
      it "is true" do
        # Box is used because it is a reference type and doesn't override the == method.
        ref = Box.new([] of Int32)
        partial = Spectator::Expectations::ValueExpectationPartial.new(ref.to_s, ref)
        matcher = Spectator::Matchers::EqualityMatcher.new(ref.to_s, ref)
        matcher.match?(partial).should be_true
      end
    end

    context "with different instances" do
      context "with same contents" do
        it "is true" do
          array1 = [1, 2, 3]
          array2 = [1, 2, 3]
          partial = Spectator::Expectations::ValueExpectationPartial.new(array1.to_s, array1)
          matcher = Spectator::Matchers::EqualityMatcher.new(array2.to_s, array2)
          matcher.match?(partial).should be_true
        end
      end

      context "with different contents" do
        it "is false" do
          array1 = [1, 2, 3]
          array2 = [4, 5, 6]
          partial = Spectator::Expectations::ValueExpectationPartial.new(array1.to_s, array1)
          matcher = Spectator::Matchers::EqualityMatcher.new(array2.to_s, array2)
          matcher.match?(partial).should be_false
        end
      end
    end
  end

  describe "#message" do
    it "mentions ==" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
      matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
      matcher.message(partial).should contain("==")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
      matcher = Spectator::Matchers::EqualityMatcher.new(label, value)
      matcher.message(partial).should contain(label)
    end
  end

  describe "#negated_message" do
    it "mentions ==" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
      matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
      matcher.negated_message(partial).should contain("==")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
      matcher = Spectator::Matchers::EqualityMatcher.new(label, value)
      matcher.message(partial).should contain(label)
    end
  end
end
