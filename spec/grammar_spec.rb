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
