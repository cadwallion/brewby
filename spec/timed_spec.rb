require 'spec_helper'

class FakeStep
  include Brewby::Timed
end

describe Brewby::Timed do
  before do
    @step = FakeStep.new
  end

  it 'has a start time' do
    expect(@step.start_time).to be_nil
  end

  it 'has an end time' do
    expect(@step.end_time).to be_nil
  end

  context 'unstarted' do
    it 'is unstarted' do
      expect(@step.started?).to be false
    end

    it 'is unended' do
      expect(@step.ended?).to be false
    end

    it 'is not in progress' do
      expect(@step.in_progress?).to be false
    end

    it 'has no elapsed time' do
      expect(@step.elapsed).to eql 0
    end
  end

  context 'started' do
    before do
      @step.start_timer
    end

    it 'is started' do
      expect(@step.started?).to be true
    end

    it 'is not ended' do
      expect(@step.ended?).to be false
    end

    it 'is in progress' do
      expect(@step.in_progress?).to be true
    end

    it 'has an elapsed time' do
      elapsed = Time.now - @step.start_time
      expect(@step.elapsed).to be_within(1).of(elapsed)
    end
  end

  context 'ended' do
    before do
      @step.start_timer
      @step.stop_timer
    end

    it 'is started' do
      expect(@step.started?).to be true
    end

    it 'is ended' do
      expect(@step.ended?).to be true
    end

    it 'is not in progress' do
      expect(@step.in_progress?).to be false
    end

    it 'has an elapsed time' do
      elapsed = @step.end_time - @step.start_time
      expect(@step.elapsed).to eql elapsed
    end
  end

  context 'timer display' do
    context 'time is greater than zero' do
      let(:time_remaining) { 3750 }

      it 'gives a formatted timer' do
        expect(@step.timer_for(time_remaining)).to eql "01:02:30"
      end

      it 'gives a formatted countdown' do
        expect(@step.countdown_for(time_remaining)).to eql "01:02:30"
      end
    end

    context 'time is less than zero' do
      let(:time_remaining) { -95 }

      it 'gives a zeroed counter for timers' do
        expect(@step.timer_for(time_remaining)).to eql "00:00:00"
      end

      it 'gives a negative counter countdown' do
        expect(@step.countdown_for(time_remaining)).to eql "+00:01:35"
      end
    end
  end
end
