{ ... }:
let
  accountId = "\${var.cloudflare_account_id}";
in
{
  variable.cloudflare_account_id = {
    type = "string";
    nullable = false;
  };

  variable.cloudflare_api_token = {
    type = "string";
    sensitive = true;
    nullable = false;
  };

  terraform.required_providers.cloudflare = {
    source = "cloudflare/cloudflare";
    version = "~> 5";
  };

  provider.cloudflare.api_token = "\${var.cloudflare_api_token}";

  resource.cloudflare_r2_bucket = {
    infra = {
      account_id = accountId;
      name = "infra";
    };

    pastyears_assets = {
      account_id = accountId;
      name = "pastyears-assets";
    };
  };

  resource.cloudflare_zone.chekur_com = {
    name = "chekur.com";
    paused = false;
    type = "full";
    account.id = accountId;
  };
}
