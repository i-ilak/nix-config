{
  config,
  ...
}:
{
  sops.secrets = {
    authentik_secret_key = {
      key = "authentik/secret_key";
      owner = "authentik";
      mode = "0440";
    };
    authentik_app_password = {
      key = "authentik/app_password";
      owner = "authentik";
      mode = "0440";
    };
  };

  sops.templates."authentik-env" = {
    content = ''
      AUTHENTIK_SECRET_KEY=${config.sops.placeholder.authentik_secret_key}
      AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder.authentik_app_password}
    '';
    owner = "root";
  };
  services.authentik =
    let
      email = "auth.ilak@hotmail.com";
    in
    {
      enable = true;
      environmentFile = config.sops.templates."authentik-env".path;
      settings = {
        email = {
          host = "smtp.office365.com";
          port = 587;
          username = email;
          use_tls = true;
          use_ssl = false;
          from = email;
        };
        disable_startup_analytics = true;
        avatars = "initials";
      };
    };
}
