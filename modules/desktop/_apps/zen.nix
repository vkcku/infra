# TODO: Integrate with BetterFox. I don't want to use it blindly because I
# want to make sure that I understand what each of the preference change is
# actually doing.
{
  lib,
  zen-browser-unwrapped,
  wrapFirefox,
  ...
}:
wrapFirefox zen-browser-unwrapped {
  extraPrefs = lib.concatLines (
    lib.mapAttrsToList
      (name: value: "user_pref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});")
      {
        # These are taken from Betterfox.
        "gfx.content.skia-font-cache-size" = 20;
        "content.notify.interval" = 100000;
        "gfx.canvas.accelerated.cache-size" = 512;
        "media.cache_readahead_limit" = 3600;
        "media.cache_resume_threshold" = 1800;
        "image.mem.decode_bytes_at_a_time" = 32768;
        "network.buffer.cache.size" = 65535;
        "network.buffer.cache.count" = 48;
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.max-urgent-start-excessive-connections-per-host" = 5;
        "network.http.request.max-start-delay" = 2;
        "network.dnsCacheExpiration" = 3600;
        "security.OCSP.enabled" = 0;
        "privacy.antitracking.isolateContentScriptResources" = true;
        "security.csp.reporting.enabled" = false;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.sessionstore.interval" = 60000;
      }
  );

  extraPolicies = {
    # keep-sorted start block=yes newline_separated=yes
    AIControls = {
      Default = {
        Value = "blocked";
        Locked = true;
      };
      Translations = {
        Value = "available";
        Locked = true;
      };
      PDFAltText = {
        Value = "available";
        Locked = true;
      };
    };

    AppAutoUpdate = false;

    AutofillAddressEnabled = true;

    AutofillCreditCardEnabled = false;

    # Not a 100% sure about this. If it turns out to be too annoying, I'll
    # just remove this.
    ClearOnShutdown = {
      CookiesAndStorage = true;
      Cache = true;
      Exceptions =
        let
          domains = [
            # keep-sorted start
            "account.proton.me"
            "accounts.google.com"
            "claude.ai"
            "drive.proton.me"
            "github.com"
            "lichess.org"
            "mail.proton.me"
            "youtube.com"
            # keep-sorted end
          ];

          mkExceptions = domain: [
            "https://${domain}"
            "https://www.${domain}"
          ];
        in
        builtins.concatMap mkExceptions domains;
    };

    Cookies.Behavior = "partition-foreign";

    CrashReportsSubmit.Enabled = false;

    # System DNS resolver will handle this.
    DNSOverHTTPS.Enabled = false;

    DefaultBrowserSettingEnabled = false;

    DisableAccounts = true;

    DisableAppUpdate = true;

    DisableSetDesktopBackground = true;

    # Allow telemetry since it helps improve Firefox.
    DisableTelemetry = false;

    DisplayBookmarksToolbar = "never";

    DontCheckDefaultBrowser = true;

    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Category = "strict";
      BaselineExceptions = true;
    };

    EncryptedMediaExtensions = {
      Enabled = true;
      Locked = true;
    };

    ExtensionSettings = {
      # keep-sorted start block=yes newline_separated=yes
      # Proton Pass
      "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
        default_area = "navbar";
      };

      # uBlock Origin. Active but hidden in the extensions menu rather than
      # pinned to the toolbar.
      "uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        default_area = "menupanel";
      };

      # Proton VPN
      "vpn@proton.ch" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-vpn-firefox-extension/latest.xpi";
        default_area = "navbar";
      };
      # keep-sorted end
    };

    GenerativeAI.Enabled = false;

    GoToIntranetSiteForSingleWordEntryInAddressBar = true;

    OfferToSaveLogins = false;

    PasswordManagerEnabled = false;

    SearchBar = "unified";

    SearchEngines = {
      Default = "ddg";
      Add = [
        {
          Name = "Github Search";
          Icon = "https://github.com/favicon.ico";
          URLTemplate = "https://github.com/search?q={searchTerms}";
          Method = "GET";
          Alias = "@gh";
        }
        {
          Name = "Nixpkgs Package Search";
          Icon = "https://nixos.org/favicon.ico";
          URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
          Method = "GET";
          Alias = "@np";
        }
      ];
      PreventInstalls = true;
      Remove = [ "Google" ];
    };

    SearchSuggestEnabled = true;

    SkipTermsOfUse = true;

    TranslateEnabled = true;
    # keep-sorted end
  };
}
