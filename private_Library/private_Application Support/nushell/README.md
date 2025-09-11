# nushell config

## Plugin nstall notes

```shell
cargo install nu_plugin_highlight --locked
plugin add ~/.cargo/bin/nu_plugin_highlight
cargo install nu_plugin_regex --locked
cargo install nu_plugin_desktop_notifications --locked
cargo install nu_plugin_port_list --locked
cargo install nu_plugin_qr_maker --locked #FAILING atm.
# Plugin add (or restart nu)
plugin add nu_plugin_inc
plugin add nu_plugin_query
plugin add nu_plugin_gstat
plugin add nu_plugin_gstats
```

Still have a few unreviewed PRs. Please have a look at them with your :heart_eyes::

- <https://github.com/github/octomesh-sync/pull/886> - @golrouhi
- <https://github.com/github/github/pull/395055> - Prep dotcom for [incoming linter](https://github.com/github/moda-linter/pull/1727) (Which is approved)
- <https://github.com/github/datadog-monitoring/pull/38416> - Add timeboxed links to Splunk queries in DD monitor messages.
