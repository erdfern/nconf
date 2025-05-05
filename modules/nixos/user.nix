{ user, ... }: {
  config = {
    users = {
      users.${user} = {
        isNormalUser = true;
        uid = 1000;
        group = "${user}";
        extraGroups = [ "wheel" ];
        home = "/home/${user}";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rupin71C/GxJ9r74UNanoxuUR7FA3u+Wc88Z/5oYh lk@kor"
        ];
      };

      groups.${user}.gid = 1000;
    };
  };
}
