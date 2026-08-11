{
  flake.modules.nixos.indra =
    { lib, ... }:
    {
      networking = {
        hostName = "indra";
        hostId = "3390dcf8";

        # The following is required to make installing Nix via `nixos-anywhere`
        # work. This is the output from running `makeNetworkConf` from
        # `nixos-infect`.
        nameservers = [
          "1.1.1.1"
        ];
        defaultGateway = "145.223.22.254";
        defaultGateway6 = {
          address = "2a02:4780:12::1";
          interface = "eth0";
        };
        dhcpcd.enable = false;
        usePredictableInterfaceNames = lib.mkForce false;
        interfaces = {
          eth0 = {
            ipv4.addresses = [
              {
                address = "145.223.22.205";
                prefixLength = 24;
              }
            ];
            ipv6.addresses = [
              {
                address = "2a02:4780:12:f97f::1";
                prefixLength = 48;
              }
              {
                address = "fe80::42e8:d4ff:feae:c8a4";
                prefixLength = 64;
              }
            ];
            ipv4.routes = [
              {
                address = "145.223.22.254";
                prefixLength = 32;
              }
            ];
            ipv6.routes = [
              {
                address = "2a02:4780:12::1";
                prefixLength = 128;
              }
            ];
          };
        };
      };

      services.udev.extraRules = ''
        ATTR{address}=="40:e8:d4:ae:c8:a4", NAME="eth0"
      '';
    };
}
