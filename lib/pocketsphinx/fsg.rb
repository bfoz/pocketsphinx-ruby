require 'set'

module Pocketsphinx
  class FSG
    attr_accessor :name
    attr_reader :start
    attr_reader :final

    class Node
      attr_accessor :transitions

      def initialize(transitions=nil)
        @transitions = transitions || {}
      end
    end

    def initialize(start, final)
      @start = start
      @final = final
    end

    # @return [Array] all of the nodes in the grammar
    def nodes(node=nil, set=nil)
      if node
        if set.add?(node)
          node.transitions.values.compact.each {|n| nodes(n, set) }
        end
        set
      else
        nodes(start, Set.new).to_a
      end
    end

    # @return [Hash]  A flattened table of transitions. The keys are 'from' and the values are transition tables of the form (word => to).
    def transitions(node=nil, hash={})
      if node
        unless hash[node]     # Avoid recursive loops
          hash[node] = node.transitions
          node.transitions.each {|(k,n)| transitions(n,hash) }  # Recursion
        end
        hash
      else
        transitions(start)
      end
    end
  end
end
