require_relative '../pocketsphinx/fsg'

module JSGF
  class Grammar
    def to_fsg
      raise StandardError, "The grammar must have at least one root" unless roots
      raise StandardError, "The grammar must contain at least one public rule" if roots.empty?
      raise StandardError, "Can't handle multiple grammar roots" if roots.size > 1

      root = roots.first.last

      final = Pocketsphinx::FSG::Node.new
      transitions = expand_atom(root, final)
      start_state = Pocketsphinx::FSG::Node.new(transitions)
      Pocketsphinx::FSG.new(start_state, final).tap {|fsg| fsg.name = grammar_name }
    end

  private

    def expand_atom(atom, end_state)
      case atom
        when JSGF::Alternation
          atom.map {|a| expand_atom(a, end_state) }.reduce {|a,b| a.merge b }
        when Array
          # Start with the last atom in the sequence and build a set of state transitions from the end
          start_state = atom.reverse.reduce(end_state) do |memo, a|
              transitions = expand_atom(a, memo)
              Pocketsphinx::FSG::Node.new(transitions)
          end
          start_state.transitions
        when Hash
          if atom[:atom]  # A bare word
            {atom[:atom] => end_state}  # Transition on the bare word
          elsif atom[:name]   # A reference to another rule (potentially recursive)
            expand_atom(rules[atom[:name]], end_state)
          end
      end
    end
  end
end
