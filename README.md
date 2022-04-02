# Dotfiles

Using https://www.chezmoi.io/ to handle the business.

Quickstart [here](https://www.chezmoi.io/quick-start/#start-using-chezmoi-on-your-current-machine)

## Usage

### On a fresh machine

Simply run this in the shell:

```shell
sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply hilli
```

On a macOS machine, be sure that you are signed into the App Store

### Codespaces

GitHub Codespaces will automatically install the dotfiles if you point it a this repos in [the Codespaces settings](https://github.com/settings/codespaces). Codespaces will trigger the `install.sh` script in the root of the repo. This is also a way to set it up if you already have a checkout of this repo.
