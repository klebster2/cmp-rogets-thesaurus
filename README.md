# Usage Notes

This is an nvim-cmp thesaurus plugin (that uses Roget's Thesaurus) created for use within neovim.

It can be downloaded using packer like so:

Generally, some improvements can be made.

If you are interested in contributing, please get in touch.

Main issues:
- Unknown performance over different operating systems

```lua
use "klebster2/cmp-rogets-thesaurus" -- packer.nvim
```

nvim-cmp wasn't designed for comparing against thousands of candidates so these improvements should be looked into to prune lists being compared


## Setup

You will need [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
After using the packer / lazy neovim setup, run require

```lua
require('cmp_rogets_thesaurus')
```

If you use lspkind, you can add a custom symbol


```lua
lspkind.init({
  symbol_map = {
    rogets_thesaurus = "",
  },
})
```


```lua
cmp.setup {
  sources = {
    { name = "rogets_thesaurus", max_item_count = 10, priority = 3, keyword_length = 4 },
  },
}
```
