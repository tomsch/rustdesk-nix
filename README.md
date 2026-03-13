# RustDesk for NixOS

Unofficial Nix package for [RustDesk](https://rustdesk.com) - open-source remote desktop (TeamViewer alternative).

## Installation

### Flake Input (NixOS/Home Manager)

```nix
{
  inputs.rustdesk.url = "github:tomsch/rustdesk-nix";

  outputs = { self, nixpkgs, rustdesk, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [{
        environment.systemPackages = [
          rustdesk.packages.x86_64-linux.default
        ];
      }];
    };
  };
}
```

### Direct Run (no install)

```bash
nix run github:tomsch/rustdesk-nix
```

## Features

- Open-source remote desktop with end-to-end encryption
- Self-hosted or public server support
- File transfer, clipboard sync, audio forwarding
- Flutter-based modern UI
- Auto-updated via GitHub Actions (checked every 6 hours)

## Update Package

```bash
./update.sh
```

## Links

- [RustDesk](https://rustdesk.com)
- [RustDesk GitHub](https://github.com/rustdesk/rustdesk)
