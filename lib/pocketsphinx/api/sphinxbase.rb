module Pocketsphinx
  module API
    module Sphinxbase
      extend FFI::Library
      ffi_lib "libsphinxbase"

      class Argument < FFI::Struct
        layout :name, :string,
          :type, :int,
          :deflt, :string,
          :doc, :string
      end

      class FSG < FFI::Struct
        layout :refcount, :int,   # Reference count
          :name, :string,         # A unique string identifier for this FSG
          :n_word, :int32,        # Number of unique words in this FSG
          :n_word_alloc, :int32,  # Number of words allocated in vocab
          :vocab, :pointer,       # char **vocab; Vocabulary for this FSG
          :silwords, :pointer,    # bitvec_t *silwords; Indicates which words are silence/fillers.
          :altwords, :pointer,    # bitvec_t *altwords; Indicates which words are pronunciation alternates.
          :lmath, :pointer,       # logmath_t *lmath; Pointer to log math computation object.
          :n_state, :int32,       # number of states in FSG
          :start_state, :int32,   # Must be in the range [0..n_state-1]
          :final_state, :int32,   # Must be in the range [0..n_state-1]
          :lw, :float,            # Language weight that's been applied to transition logprobs
          :trans, :pointer,       # trans_list_t *trans; Transitions out of each state, if any.
          :link_alloc, :pointer   # listelem_alloc_t *link_alloc; Allocator for FSG links.
      end

      # TODO: Document on ruby side?
      attach_function :cmd_ln_parse_r, [:pointer, :pointer, :int32, :pointer, :int], :pointer
      attach_function :cmd_ln_float_r, [:pointer, :string], :double
      attach_function :cmd_ln_set_float_r, [:pointer, :string, :double], :void
      attach_function :cmd_ln_int_r, [:pointer, :string], :int
      attach_function :cmd_ln_set_int_r, [:pointer, :string, :int], :void
      attach_function :cmd_ln_str_r, [:pointer, :string], :string
      attach_function :cmd_ln_set_str_r, [:pointer, :string, :string], :void
      attach_function :err_set_debug_level, [:int], :int
      attach_function :err_set_logfile, [:string], :int
      attach_function :err_set_logfp, [:pointer], :void

      # @group logmath.h

      # Convert linear floating point number to integer log in base B.
      # int logmath_log(logmath_t *lmath, float64 p);
      attach_function :logmath_log, [:pointer, :double], :int

      # @endgroup

      # @group fsg_model.h

      # int fsg_model_free(fsg_model_t *fsg);
      attach_function :fsg_model_free, [FSG.by_ref], :void

      # fsg_model_t *fsg_model_init(char const *name, logmath_t *lmath, float32 lw, int32 n_state);
      attach_function :fsg_model_init, [:string, :pointer, :float, :int32], FSG.by_ref

      # int fsg_model_word_add(fsg_model_t *fsg, char const *word);
      attach_function :fsg_model_word_add, [FSG.by_ref, :string], :int

      # void fsg_model_trans_add(fsg_model_t * fsg, int32 from, int32 to, int32 logp, int32 wid);
      attach_function :fsg_model_trans_add, [FSG.by_ref, :int32, :int32, :int32, :int], :void

      # @endgroup
    end
  end
end
