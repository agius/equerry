require 'spec_helper'

describe Equerry do
  let(:default_index) { 'equerry_test' }
  let(:default_type)  { 'game_devs' }
  let(:logger)        { Logger.new(STDOUT) }

  subject { Equerry }

  it 'has a version number' do
    expect(Equerry::VERSION).not_to be nil
  end

  it 'produces a base elasticsearch client' do
    expect(subject.client).to be_a(Elasticsearch::Transport::Client)
  end

  context 'can be configured by' do
    before { subject.deconfigure }
    
    after do
      expect(subject.default_index).to  eq('equerry_test')
      expect(subject.default_type).to   eq('game_devs')
      expect(subject.logger).to         eq(logger)
    end

    specify 'an options hash' do
      subject.configure(
        default_index:  default_index,
        default_type:   default_type,
        logger:         logger
      )
    end

    specify 'a block' do
      subject.configure do |config|
        config.default_index = default_index
        config.default_type  = default_type
        config.logger        = logger
      end
    end
  end

  context 'when configured' do
    before do
      subject.configure do |config|
        config.default_index = default_index
        config.default_type  = default_type
        config.logger        = logger
      end
    end

    it 'can drop and create the index' do
      subject.drop if subject.exists?
      subject.create
      expect(subject.exists?).to eq(true)
    end

    it 'can drop the index' do
      subject.create unless subject.exists?
      subject.drop
      expect(subject.exists?).to eq(false)
    end

    context 'and the index exists' do
      before do
        subject.drop if subject.exists?
        subject.create
      end

      it 'can put a mapping' do
        expect{subject.put_mapping(properties: { id: {type: :integer, store: true } })}.to_not raise_error
      end

      it 'can refresh the index' do
        expect{subject.refresh}.to_not raise_error
      end

      it 'can count the total number of documents' do
        expect(subject.count).to eq(0)
      end

      it 'can index a document' do
        subject.index(body: FIXTURES[:sakurai])
        subject.refresh
        expect(subject.count).to eq(1)
      end

      it 'can bulk index multiple documents' do
        subject.bulk(documents: [FIXTURES[:sakurai], FIXTURES[:mizuguchi]])
        subject.refresh
        expect(subject.count).to eq(2)
      end

      it 'can search for documents' do
        subject.index(body: FIXTURES[:sakurai])
        subject.refresh
        results = subject.search(body: { query: { match_all: {} }})
        expect(results['hits']['total']).to eq(1)
      end
    end
  end
end
