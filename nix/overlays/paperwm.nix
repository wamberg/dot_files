(self: super: {
  gnomeExtensions = super.gnomeExtensions // {
    paperwm = super.gnomeExtensions.paperwm.overrideDerivation (old: {
      version = "42.0";
      src = super.fetchFromGitHub {
        owner = "PaperWM-community";
        repo = "PaperWM";
        rev = "gnome-42";
        sha256 = "sha256-dBN5CdxUzF7UqIRYjfT5EUCetHs1ZD+1KCNv3oSMRuE=";
      };
    });
  };
})
