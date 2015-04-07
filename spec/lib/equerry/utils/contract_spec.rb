require 'spec_helper'

describe Equerry::Utils::Contract do

  class MyClass
    extend Equerry::Utils::Contract

    contract Hash[
      num: Numeric,
      str: String,
      list: [:valid, :also_valid],
      sym: :a_symbol,
      prok: Proc.new {
        @prok ? @prok : "Not valid"
      },
      time: Time.new(2015, 2, 1)
    ]

    def initialize(options = {})
      options.each do |ivar, val|
        instance_variable_set("@#{ivar}", val)
      end
      self.class.validate(self)
    end
  end

  let(:time) { Time.new(2015, 2, 1) }

  let(:valid_params) do
    Hash[
      num: 123,
      str: 'a string',
      list: :valid,
      sym: :a_symbol,
      prok: true,
      time: time
    ]
  end

  subject { MyClass }

  def check(options = {})
    subject.new(valid_params.merge(options))
  end

  it 'is valid with default params' do
    expect{check}.to_not raise_error
  end

  it 'validates module type' do
    expect{check(num: 'not a num')}.to raise_error
  end

  it 'validates class type' do
    expect{check(str: 123)}.to raise_error
  end

  it 'validates lists' do
    expect{check(list: :invalid)}.to raise_error
  end

  it 'validates with a proc' do
    expect{check(prok: false)}.to raise_error
  end

  it 'validates by eql?' do
    expect{check(time: time + 1)}.to raise_error
  end

  it 'validates by ==' do
    expect{check(sym: :wrong_symbol)}.to raise_error
  end

end