{
  # Client-side state-encryption passphrase. Supplied at runtime via
  # TF_VAR_state_passphrase (decrypted from sops), so the key never lands in the
  # Nix store or the committed config.
  variable.state_passphrase = {
    type = "string";
    sensitive = true;
    nullable = false;
  };

  terraform = {
    backend.s3 = {
      bucket = "infra";
      key = "opentofu.tfstate";
      region = "auto";

      use_path_style = true;
      use_lockfile = true;
      skip_requesting_account_id = true;
      skip_metadata_api_check = true;
      skip_region_validation = true;
      skip_credentials_validation = true;
    };

    encryption =
      let
        keyProvider = "passphrase";
        method = "default";
      in
      {
        key_provider.pbkdf2.${keyProvider}.passphrase = "\${var.state_passphrase}";

        method.aes_gcm.${method}.keys = "\${key_provider.pbkdf2.${keyProvider}}";

        state = {
          method = "method.aes_gcm.${method}";
          enforced = true;
        };

        plan = {
          method = "method.aes_gcm.${method}";
          enforced = true;
        };
      };
  };
}
