# OrderedForward
Sourcemod Forward ordering isn't guaranteed, this plugin manages forward with ordered by config.

Config for example
```json
"config"
{
	"a.smx" {}
	"c.smx" {}
	"b.smx" {}
	"d.smx" {}
}
```
In this config, plugin forward will fire order by A -> C -> B -> D plugin.

This plugin is still under development. Any PRs are welcome.