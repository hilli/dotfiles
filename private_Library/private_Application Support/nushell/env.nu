# env.nu
#
# Installed by:
# version = "0.105.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

use std/util "path add"

#
# Paths
#
path add /opt/homebrew/bin
path add /opt/homebrew/sbin
path add /System/Cryptexes/App/usr/bin
path add /usr/local/bin
path add /bin
path add /sbin
path add /usr/bin
path add /usr/sbin
path add /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin
path add /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin
path add /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
path add /Library/Apple/usr/bin
path add /Applications/iTerm.app/Contents/Resources/utilities
path add /usr/local/bin
path add /opt/local/bin
path add /opt/local/sbin
path add ~/.cargo/bin
path add ~/.go/bin
path add ~/.lmstudio/bin
path add ~/.orbstack/bin
path add ~/.rbenv/shims
path add ~/bin


$env.CARAPACE_BRIDGES = 'zsh,fish,bash' # optional
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu


# 
# Plugins
# 
const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
  ...$NU_PLUGIN_DIRS
]

# Plugins config
$env.config.plugins.highlight.true_colors = true
