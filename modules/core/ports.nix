{
  flake.modules.nixos.core =
    { lib, config, ... }:
    let
      requests = config.infra.portRequests;
      explicitPorts = lib.attrsets.filterAttrs (_: v: builtins.isInt v) requests;

      basePort = 3000;

      # Find the next free port using the given candidate as the port
      # preference. If the given candidate has not been used, then return
      # that else increment the candidate by one and keep looking.
      getFreePort =
        used: candidate:
        if builtins.any (p: candidate == p) used then getFreePort (candidate + 1) else candidate;

      # Allocate all the ports for the services that requested
      # auto-allocation. The used ports (and the assigned ports) are tracked
      # via the accumulator.
      mkAutoPorts = builtins.foldl' (
        { used, ports }:
        name:
        let
          freePort = getFreePort used basePort;
        in
        {
          used = used ++ [ freePort ];
          ports = ports // {
            "${name}" = freePort;
          };
        }
      );
      autoPorts =
        let
          acc = {
            used = builtins.attrValues explicitPorts;
            ports = { };
          };

          services =
            let
              names = builtins.attrNames (lib.attrsets.filterAttrs (_: v: builtins.isInt v == false) requests);
            in
            # Sorting ensures the port allocation is deterministic for this
            # given list of services. This does mean that when new services
            # are added the ports may change, but that should be fine.
            #
            # TODO: Explore if calculating the initial candidate port based
            # on the hash of the name would be better instead of always
            # relying on basePort.
            builtins.sort builtins.lessThan names;
        in
        (mkAutoPorts acc services).ports;

      ports = autoPorts // explicitPorts;
    in
    {
      options.infra = {
        portRequests = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.oneOf [
              lib.types.port
              lib.types.bool
            ]
          );
          description = ''
            Request for a port for each service. If an explicit port is
            given, then that is used else an auto-allocated port is used. The
            auto-allocated port is deterministic for a given set of services.
          '';
          default = { };
        };

        ports = lib.mkOption {
          type = lib.types.attrsOf lib.types.port;
          readOnly = true;
          description = ''
            The ports used per service.

            The values for this should not be set since this is
            auto-generated. Use `portRequests` instead.

            This ensures that all the ports used for various services are defined
            in a consistent manner and allows for checking against multiple
            services trying to use the same ports.
          '';
        };
      };

      config = {
        infra.ports = ports;

        assertions = [
          {
            assertion =
              lib.length (lib.unique (builtins.attrValues ports)) == lib.length (builtins.attrNames ports);
            message = "two services were assigned the same port";
          }
        ];
      };
    };
}
