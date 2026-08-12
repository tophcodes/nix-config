{
  flake.modules.homeManager.mic-chain = {pkgs, ...}: let
    # Absolute store paths, per ADR-021: the chain must not resolve its
    # plugins through LADSPA_PATH. The suffix is required — filter-chain only
    # appends ".so" when resolving a bare name against the search path, not
    # for an absolute path, despite what the upstream example claims.
    rnnoise = "${pkgs.rnnoise-plugin.ladspa}/lib/ladspa/librnnoise_ladspa.so";
    deepFilter = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";

    # A voice chain: 80 Hz high-pass into one denoiser, mono throughout.
    # `capture.props` only — linking a capture chain into the playback graph
    # merges two independently clocked USB devices into one scheduling group
    # and forces the follower to resample against a clock it does not share.
    mkChain = {
      name,
      description,
      plugin,
      label,
      inputPort,
      outputPort,
      control,
    }: ''
      context.modules = [
        { name = libpipewire-module-filter-chain
          flags = [ nofail ]
          args = {
            node.description = "${description}"
            media.name       = "${description}"
            filter.graph = {
              nodes = [
                {
                  type    = builtin
                  name    = highpass
                  label   = bq_highpass
                  control = { "Freq" = 80.0 "Q" = 0.707 }
                }
                {
                  type    = ladspa
                  name    = denoise
                  plugin  = "${plugin}"
                  label   = ${label}
                  control = { ${control} }
                }
              ]
              links = [
                { output = "highpass:Out" input = "denoise:${inputPort}" }
              ]
              # Without these the graph is replicated once per channel, which
              # runs the denoiser twice on a source that carries one voice.
              inputs  = [ "highpass:In" ]
              outputs = [ "denoise:${outputPort}" ]
            }
            audio.channels = 1
            audio.position = [ MONO ]
            capture.props = {
              node.name      = "effect_input.${name}"
              node.passive   = true
              audio.channels = 1
              audio.position = [ MONO ]
            }
            playback.props = {
              node.name      = "effect_output.${name}"
              media.class    = Audio/Source
              audio.channels = 1
              audio.position = [ MONO ]
            }
          }
        }
      ]
    '';
  in {
    xdg.configFile = {
      "pipewire/pipewire.conf.d/60-mic-rnnoise.conf".text = mkChain {
        name = "mic_rnnoise";
        description = "Mic (rnnoise)";
        plugin = rnnoise;
        label = "noise_suppressor_mono";
        inputPort = "Input";
        outputPort = "Output";
        control = ''"VAD Threshold (%)" = 50.0 "VAD Grace Period (ms)" = 200.0'';
      };

      "pipewire/pipewire.conf.d/61-mic-deepfilter.conf".text = mkChain {
        name = "mic_deepfilter";
        description = "Mic (DeepFilter)";
        plugin = deepFilter;
        label = "deep_filter_mono";
        inputPort = "Audio In";
        outputPort = "Audio Out";
        control = ''"Attenuation Limit (dB)" = 24.0'';
      };
    };
  };
}
