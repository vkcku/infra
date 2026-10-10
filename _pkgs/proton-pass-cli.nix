{
  symlinkJoin,
  makeBinaryWrapper,
  proton-pass-cli,
}:
# Ensure the dbus keyring is used.
symlinkJoin {
  name = "proton-pass-cli-${proton-pass-cli.version}";
  paths = [ proton-pass-cli ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    wrapProgram $out/bin/pass-cli --set PROTON_PASS_LINUX_KEYRING dbus
  '';

  meta = proton-pass-cli.meta // {
    description = "${proton-pass-cli.meta.description} (using the dbus keyring)";
  };
}
