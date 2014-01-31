require 'spec_helper'

class FakeStep
  include Brewby::Timed
end

describe Brewby::Timed do
  before do
    @step = FakeStep.new
  end

  it 'has a start time' do
    @step.start_time.should be_nil
  end

  it 'has an end time' do
    @step.end_time.should be_nil
  end

  context 'unstarted' do
    it 'is unstarted' do
      @step.started?.should be_false
    end

    it 'is unended' do
      @step.ended?.should be_false
    end

    it 'is not in progress' do
      @step.in_progress?.should be_false
    end
    
    it 'has no elapsed time' do
      @step.elapsed.should == 0
    end
  end

  context 'started' do
    before do
      @step.start_timer
    end

    it 'is started' do
      @step.started?.should be_true
    end

    it 'is not ended' do
      @step.ended?.should be_false
    end

    it 'is in progress' do
      @step.in_progress?.should be_true
    end

    it 'has an elapsed time' do
      elapsed = Time.now - @step.start_time
      @step.elapsed.should be_within(1).of(elapsed)
    end
  end

  context 'ended' do
    before do
      @step.start_timer
      @step.stop_timer
    end

    it 'is started' do
      @step.started?.should be_true
    end

    it 'is ended' do
      @step.ended?.should be_true
    end

    it 'is not in progress' do
      @step.in_progress?.should be_false
    end

    it 'has an elapsed time' do
      elapsed = @step.end_time - @step.start_time
      @step.elapsed.should == elapsed
    end
  end

  context 'timer display' do
    context 'time is greater than zero' do
      let(:time_remaining) { 3750 }

      it 'gives a formatted timer' do
        @step.timer_for(time_remaining).should == "01:02:30"
      end

      it 'gives a formatted countdown' do
        @step.countdown_for(time_remaining).should == "01:02:30"
      end
    end

    context 'time is less than zero' do
      let(:time_remaining) { -95 }

      it 'gives a zeroed counter for timers' do
        @step.timer_for(time_remaining).should == "00:00:00"
      end

      it 'gives a negative counter countdown' do
        @step.countdown_for(time_remaining).should == "+00:01:35"
      end
    end
  end
end
