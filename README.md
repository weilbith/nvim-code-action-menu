# NeoVim Code Action Menu

> **NOTE:**
> This is still a beta version. Though it runs quite stable since some months,
> it has not been tested with many language servers. Moreover there is a good
> amount of documentation missing.

![gscreenshot_2021-09-28-094359](https://user-images.githubusercontent.com/12543647/135045142-dedfe9bb-01a0-4ed0-8d40-1dc4f2c2b254.png)

This plugin provides a handy pop-up menu for code actions. Its key competence is
to provide the user with more detailed insights for each available code action.
Such include meta data as well as a preview diff for certain types of actions.
These includes:
  - descriptive title (usually shown by all code action "menu" solutions)
  - kind of the action (e.g. refactor, command, quickfix, organize imports, ...)
  - name of the action
  - if the action is the preferred one according to the server (preferred
    actions get automatically sorted to the top of the menu)
  - if the action is disabled (disabled actions can be used and get
    automatically sorted to the bottom of the menu with a special hightlight)
  - a preview of the changes this action will do in a diff view for all affected
    files (includes a diff count box visualization as GitHub pul requests do)
  - ...more will come, especially when servers start to use the `dataSupport`
    capability for the code action provider

The experience for all these features might vary according to the implementation
of the used language server. Especially for the diff view, do some servers still
use the old code action data scheme from older Language Server Protocol versions
which include less information for the clients. However this plugin tries to
inspect those actions more deeply and try to parse as much information as
possible.

This plugin is just a menu for code actions. Nothing more and nothing less. It
is a minimal plugin that focuses on one single task. It tries to be a contrast
to other plugins which also provide a code action menu but being more advanced
a do not provide any other functionality.

## Installation

Install the plugin with your favorite manager tool. Here is an example using
[packer.nvim](https://github.com/wbthomason/packer.nvim/issues):

```lua
require('packer').use({
  'weilbith/nvim-code-action-menu',
  cmd = 'CodeActionMenu',
})
```

It is recommended to use the
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) plugin to attach
language clients to your buffers.

Furthermore is quite handy to also use the
[nvim-lightbulb](https://github.com/kosayoda/nvim-lightbulb) plugin. It will
automatically inform the user visually if any code actions are available for the
current cursor location.

Please note that LSP and other features for this plugin require you to have at
least `v0.5.0` of NeoVim.

## Usage

The plugin has a single command only: `CodeActionMenu` This command works in
normal mode, as well as visual mode. For the latter mode it will switch to the
code range mode automatically.
The menu can be navigated as usual with `j` and `k`. The docked windows will
always display further information for the currently selected action. Hitting
`<CR>` will execute the currently selected code action. Alternatively you can
type the number in front of the list entry to jump directly to this action and
apply it right away. In any case the menu window will close itself. If you want
to manually close the window without selecting an action, just hit `<Esc>` or
`q`.

This plugin only supports nvim_lsp, if you are using coc.nvim, you can install
[coc-code-action-menu.nvim](https://github.com/xiyaowong/coc-code-action-menu.nvim)
to add support for coc.nvim.

## Customization

The plugin allows for a bunch of customization. While there is no classic
configuration (yet) it can be adapted by using traditional (Neo)Vim techniques.
Each part of the menu uses its own filetype. This gets used to separate the
logic implementation in Lua from other parts like highlighting, buffer options
and mappings. As beautiful side effect is that the user can do so too. This
means you can just define some
`after/{ftplugin,syntax}/code-action-menu-{menu,details,diff,warning}.{vim,lua}`
files yourself and get the full power of customization.

At the current state of documentation I must redirect you to the syntax files in
the source code of the plugin to get a list of available highlight groups. The
user can simply overwrite any of the default mappings to his liking.

### Window Appearance

The following global variables can be set to alternate the appearance of the
windows:

```lua
vim.g.code_action_menu_window_border = 'single'
```

```vim
let g:code_action_menu_window_border = 'single'
```
### Disable parts of the UI

The following global variables can be set to disable parts of the user
interface:

```lua
vim.g.code_action_menu_show_details = false
vim.g.code_action_menu_show_diff = false
vim.g.code_action_menu_show_action_kind = false
```

```vim
let g:code_action_menu_show_details = v:false
let g:code_action_menu_show_diff = v:false
let g:code_action_menu_show_action_kind = v:false
```
