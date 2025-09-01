let
  drainpixie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjrd3Drz463j6IpRJzPIm+KczyhYE7upw7rjlGTlMnJ";
in {
  "wakapi-salt".publicKeys = [drainpixie];
  "wakapi-conf".publicKeys = [drainpixie];
}
