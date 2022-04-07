# Dotfiles

Using https://www.chezmoi.io/ to handle the business.

Chezmoi Quickstart [here](https://www.chezmoi.io/quick-start/#start-using-chezmoi-on-your-current-machine).

Files here only handle the business for Linux and macOS (Chezmoi supports a lot more platforms thanks to [Go](https://go.dev/)).

## Usage

### On a fresh machine

Simply run this in the shell:

```shell
sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply hilli
```

On a macOS machine, be sure that you are signed into the App Store

### Codespaces

GitHub Codespaces will automatically install the dotfiles if you point it a this repos in [the Codespaces settings](https://github.com/settings/codespaces) (You should fork it first and at least change vars in `.chezmoi.yaml.tmpl`). Codespaces will trigger the `install.sh` script in the root of the repo. This is also a way to set it up if you already have a checkout of this repo.

Codespaces puts this repo in `/workspaces/.codespaces/.persistedshare/dotfiles/` (No matter the name of you dotfiles repo). You can find logs in `/workspaces/.codespaces/.persistedshare/` where `creation.log` is the one you want to look at in the case of debugging your dotfiles setup.
