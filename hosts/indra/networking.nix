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
        defaultGateway = "89.116.122.254";
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
                address = "89.116.122.108";
                prefixLength = 24;
              }
            ];
            ipv6.addresses = [
              {
                address = "2a02:4780:12:2aa6::1";
                prefixLength = 48;
              }
              {
                address = "fe80::6ae8:d4ff:fec4:5757";
                prefixLength = 64;
              }
            ];
            ipv4.routes = [
              {
                address = "89.116.122.254";
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
        ATTR{address}=="68:e8:d4:c4:57:57", NAME="eth0"
      '';
    };
}
