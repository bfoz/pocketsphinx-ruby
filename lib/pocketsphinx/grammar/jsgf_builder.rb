require 'jsgf'

module Pocketsphinx
  module Grammar
    class JsgfBuilder
      def initialize
        @sentences = []
      end

      def sentence(sentence)
        @sentences << sentence
      end

      def jsgf
        atom = {atom:@sentences.map(&:downcase).join(' | '), weight:1.0, tags:{}}
        JSGF::Grammar.new(name:'default', public_rules:{'sentence' => [atom]}).to_s
      end
    end
  end
end
