# Usage Notes

This is an nvim-cmp thesaurus plugin (that uses Roget's Thesaurus) created for use within neovim.

It can be downloaded using packer like so:

```lua
    use "klebster2/cmp-rogets-thesaurus" -- packer.nvim
```

Generally, some improvements need to be made.

If you are interested in contributing, please get in touch.

Main issues:
- Slow initial loading
- Slow completion
    slow

- Proposed solution - split the thesaurus into shards organised based on the onsets of words
  or use a prepared thesaurus (not a tsv file)

nvim-cmp wasn't designed for comparing against thousands of candidates so these improvements should be looked into to prune lists being compared


## Setup

After using the packer / lazy neovim setup, run require

```lua
require('cmp_rogets_thesaurus')
```

If you use lspkind, you can add a custom symbol


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
    { name = "rogets_thesaurus", max_item_count = 10, priority = 3, keyword_length = 4 },
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
