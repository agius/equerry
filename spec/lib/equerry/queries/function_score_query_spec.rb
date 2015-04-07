require 'spec_helper'

describe Equerry::Queries::FunctionScoreQuery do

  context 'contract violations' do
    it 'only accepts numbers for boost' do
      expect{subject.new(boost: 'invalid')}.to raise_error
    end

    it 'only accepts numbers for min_score' do
      expect{subject.new(min_score: 'invalid')}.to raise_error
    end
  end

end