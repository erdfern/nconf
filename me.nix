{
  user = "j"; # jay jade joy
  email = "jay@erdfern.dev";
  domain = "";
  ssh.pubKeys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGbfWj2zAADpQBzrqydUq40755qifLmzOMp3We32hs7hAAAAE3NzaDpsYXguZXJkZmVybi5kZXY= ssh:lax.erdfern.dev"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINbSc82sYDBWblZ53C9kGWBZhApXu1x65/z/MLJ40OgNAAAAFnNzaDpzdHJpY3QuZXJkZmVybi5kZXY= ssh:strict.erdfern.dev"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMME0ww1s7x37uSONLhXUPVjnXbErrxEC432Fp9l8qhzAAAAFnNzaDpsYXgubmsuZXJkZmVybi5kZXY= ssh:lax.nk.erdfern.dev"
  ];
  gpg = {
    signKey = "F6C79FF4E1D142EE";
  };
  git = {
    user = "erdfern";
    email = "git@mail.erdfern.com";
  };
}
