require 'spec_helper'

describe Booker::Models::ItineraryTimeSlotsList do
  it 'has the correct attributes' do
    ['ItineraryTimeSlots'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
