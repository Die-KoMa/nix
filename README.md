# The New Infrastructure eXperience

<!--toc:start-->
- [The New Infrastructure eXperience](#the-new-infrastructure-experience)
  - [Deployment](#deployment)
  - [Updating](#updating)
  - [Upgrading](#upgrading)
  - [Machines](#machines)
  - [Modules](#modules)
  - [Secrets](#secrets)
  - [DNS](#dns)
<!--toc:end-->

This repository contains the configuration for the
[KoMa](https://die-koma.org) computing infrastructure. We run NixOS,
with all configuration exposed through this flake.

## Deployment

We use [wat](https://github.com/thelegy/wat) for deployment. Use
`deploy brausefrosch switch` to switch to a new configuration, or
`deploy brausefrosch reboot` to reboot into a new configuration.

## Updating
Run `nix flake update --commit-lock-file` to update all flake inputs
(most importantly, the version of `nixpkgs` used). Afterwards, 

## Upgrading
To upgrade to a newer [NixOS](https://nixos.org) release, check the
[release
notes](https://nixos.org/manual/nixos/unstable/release-notes.html) and
update `flake.nix` to point to the corresponding branch. Then proceed
with “Updating” and “Deployment”, as outlined above.

## Machines

We are currently using a single machine, `brausefrosch` hosted on the
[Hetzner cloud](https://hetzner.com/cloud). Machine configurations go
below `machines/<hostname>`. Machine-specific secrets can go into
`machines/<hostname>/secrets.yaml`, see below for details.

## Modules

Machine-independent configuration is encapsulated in individual
modules, each located below `modules/`, and providing relevant
configuration options for customisation. Individual machines can
then enable these modules.

## Secrets

Secrets are managed using
[sops-nix](https://github.com/Mic92/sops-nix). `.sops.yaml` configures
which secrets are encrypted with which keys. Use `nix run
.#sops-rekey` to update encrypted files after modifying these
associations. Use `nix run .#sops …/….yaml` to edit a file containing
encrypted secrets.

## DNS

We use [dnscontrol])(https://dnscontrol.org) to manage our DNS
zones. The main zones are `die-koma.org` and `komapedia.org`, which
are both managed at [INWX](https://inwx.de). We use a
[deSEC](https://desec.io) zone for dynamic DNS-01 ACME challenges. Use
`nix run .#dnscontrol preview` to view the differences between
configured and actual zone entries, and `nix run .#dnscontrol push` to
push the configured zones to the nameservers.
