require 'jsgf'

require_relative '../../jsgf/grammar'

module Pocketsphinx
  module Configuration
    class Grammar < Default
      attr_accessor :grammar

      # @param path [String,JSGF::Grammar]  the JSGF file to load, or a {JSGF::Grammar}
      def initialize(*args, &block)#(grammar_path = nil)
        super()

        raise "Either a path or block is required to create a JSGF grammar" if args.empty? && !block_given?

        if block_given?
          builder = Pocketsphinx::Grammar::JsgfBuilder.new
          builder.instance_eval(&block)
          @grammar = builder.jsgf
        else
          @grammar = args.first.is_a?(JSGF::Grammar) ? args.first : JSGF.read(*args) rescue raise('Invalid JSGF grammar')
        end
      end

      def fsg_model(decoder=nil)
        fsg = grammar.to_fsg

        # Create indices for all of the nodes in the FSG
        indices = Hash[[*fsg.nodes.map.with_index]]

        if decoder
          ps_decoder = API::Pocketsphinx::Decoder.new(decoder.ps_decoder)
          lmath = ps_decoder[:lmath]
          lw = API::Sphinxbase.cmd_ln_float_r(ps_config, '-lw');

          fsg_model = API::Sphinxbase.fsg_model_init(grammar.grammar_name, lmath, lw, indices.size)
          fsg_model[:start_state] = indices[fsg.start]
          fsg_model[:final_state] = indices[fsg.final]

          fsg.transitions.each do |(from, h)|
            h.each do |(word, to)|
              wordID = API::Sphinxbase.fsg_model_word_add(fsg_model, word)
              log = API::Sphinxbase.logmath_log(lmath, 1.0)
              API::Sphinxbase.fsg_model_trans_add(fsg_model, indices[from], indices[to], log, wordID)
            end
          end

          fsg_model
        end
      end

      # Since JSGF strings are not supported in Pocketsphinx configuration (only files),
      # we use the post_init_decoder hook to configure the JSGF
      def post_init_decoder(decoder)
        decoder.unset_search
        raise(StandardError, "Can't set a grammar without @grammar") unless grammar

        fsg = fsg_model(decoder)
        API::Pocketsphinx.ps_set_fsg(decoder.ps_decoder, grammar.grammar_name, fsg);
        API::Sphinxbase.fsg_model_free(fsg)

        decoder.set_search(grammar.grammar_name)
      end
    end
  end
end
