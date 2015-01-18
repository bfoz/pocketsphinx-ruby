module Pocketsphinx
  module API
    module Pocketsphinx
      extend FFI::Library
      ffi_lib "libpocketsphinx"

      typedef :pointer, :decoder
      typedef :pointer, :configuration

      class PTimer < FFI::Struct
        layout :name, :string,
          :t_cpu, :double,
          :t_elapsed, :double,
          :t_tot_cpu, :double,
          :start_cpu, :double,
          :start_elapsed, :double
      end

      class Decoder < FFI::Struct
        layout :config, :pointer,
          :refcount, :int,
          :acmod, :pointer,
          :dict, :pointer,
          :d2p, :pointer,
          :lmath, :pointer,
          :searches, :pointer,
          :search, :pointer,
          :phone_loop, :pointer,
          :pl_window, :int,
          :uttno, :int, 4,  # uint32
          :uttid, :string,
          :perf, PTimer,
          :n_frame, :int, 4,  # uint32
          :mfclogdir, :string,
          :rawlogdir, :string,
          :senlogdir, :string
      end

      attach_function :ps_init, [:configuration], :decoder
      attach_function :ps_reinit, [:decoder, :configuration], :int
      attach_function :ps_default_search_args, [:pointer], :void
      attach_function :ps_args, [], :pointer
      attach_function :ps_decode_raw, [:decoder, :pointer, :string, :long], :int
      attach_function :ps_process_raw, [:decoder, :pointer, :size_t, :int, :int], :int
      attach_function :ps_start_utt, [:decoder, :string], :int
      attach_function :ps_end_utt, [:decoder], :int
      attach_function :ps_get_in_speech, [:decoder], :uint8
      attach_function :ps_get_hyp, [:decoder, :pointer, :pointer], :string
      attach_function :ps_unset_search, [:decoder, :string], :int
      attach_function :ps_get_search, [:decoder], :string
      attach_function :ps_set_search, [:decoder, :string], :int

      # @group ps_search.h

      # int ps_set_fsg(ps_decoder_t *ps, const char *name, fsg_model_t *fsg);
      attach_function :ps_set_fsg, [:decoder, :string, API::Sphinxbase::FSG.by_ref], :int

      # @endgroup
    end
  end
end
