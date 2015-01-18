require 'spec_helper'

describe Pocketsphinx::Configuration::Grammar do
  it "raises an exception when neither a file nor block are given" do
    expect { Pocketsphinx::Configuration::Grammar.new }.to raise_exception "Either a path or block is required to create a JSGF grammar"
  end

  context "reading a grammar from a file" do
    let(:grammar_path) { grammar :goforward }
    subject { Pocketsphinx::Configuration::Grammar.new(grammar_path) }

    it "reads a grammar from a file" do
      expect(subject.grammar.rules.count).to eq(4)
    end

    context "the grammar file is invalid" do
      let(:grammar_path) { grammar :invalid }

      it "raises an exception" do
        expect { subject }.to raise_exception "Invalid JSGF grammar"
      end
    end
  end

  context 'converting a grammar to an FSG' do
    let(:grammar_path) { grammar :goforward }
    subject { Pocketsphinx::Configuration::Grammar.new(grammar_path) }

    it 'must handle a single rule with a single atom' do
      grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=one;').parse
      fsg = grammar.to_fsg
      expect(fsg).to be_a(Pocketsphinx::FSG)
    end

    it 'must handle a single rule with a sequence of atoms' do
      grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=one two;').parse
      fsg = grammar.to_fsg
      expect(fsg).to be_a(Pocketsphinx::FSG)
    end

    it 'must handle a single rule with an alternation of atoms' do
      grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=one | two | three;').parse
      fsg = grammar.to_fsg
      expect(fsg).to be_a(Pocketsphinx::FSG)
    end

    it 'must handle multiple public rules' do
      grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule1>=one | two | three; public <rule2>=four | five | six;').parse
      fsg = grammar.to_fsg
      expect(fsg).to be_a(Pocketsphinx::FSG)
    end

    it 'create an fsg_model_t' do
      subject.fsg_model
    end

    it 'create an fsg_model_t with a decoder' do
      decoder = Pocketsphinx::Decoder.new(subject)
      subject.fsg_model(decoder)
    end
  end

  context "building a grammer from a block" do
    subject do
      Pocketsphinx::Configuration::Grammar.new do
        sentence "Go forward ten meters"
        sentence "Go backward ten meters"
      end
    end

    it "builds a grammar from a block" do
      expect(subject.grammar.to_s).to eq(File.read grammar(:sentences))
    end
  end

  private

  def grammar(name)
    "spec/assets/grammars/#{name}.gram"
  end
end
