# Usage Notes

This is an nvim-cmp thesaurus plugin (that uses Roget's Thesaurus) created for use within neovim.

It can be downloaded using packer like so:

```lua
    use "klebster2/cmp-rogets-thesaurus" -- packer.nvim
```

Generally, some improvements need to be made.

If you are interested in contributing, please get in touch.

```lua
require("rogets_thesaurus") ---- TODO - make this a plugin <<< $HOME/.config/nvim/lua/plugins/nvim-cmp/thesaurus.lua
```

```lua
lspkind.init({
  symbol_map = {
    thesaurus = "",
  },
})
```

```lua
cmp.setup {
  sources = {
    { name = "thesaurus", max_item_count = 10, priority = 3, keyword_length = 4 },
  },
  formatting = {
    fields = {
      cmp.ItemField.Menu,
      cmp.ItemField.Abbr,
      cmp.ItemField.Kind,
    },
    format = function(entry, vim_item)
      vim_item.kind = string.format(
        "%s %s",
        (lsp_symbols[vim_item.kind]),
        (lspkind.presets.default[vim_item.kind])
      )
      vim_item.menu = ({
        thesaurus = "",  -- Custom thesaurus
      })[entry.source.name]
      return vim_item
  end,
  },
}
```
