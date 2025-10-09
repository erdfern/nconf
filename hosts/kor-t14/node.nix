{
  # https://colmena.cli.rs/unstable/reference/deployment.html
  deployment = {
    targetUser = "j";
    # targetHost = "192.168.178.54";
    targetPort = 22;
    privilegeEscalationCommand = [ "sudo" ];

    tags = [ "laptop" ];
  };
}
