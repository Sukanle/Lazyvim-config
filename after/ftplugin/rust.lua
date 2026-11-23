-- Rust lifetimes start with an apostrophe (`&'a str`), so auto-pairing `'`
-- produces `''` and gets in the way. Override only the single-quote mapping
-- for Rust buffers; other mini.pairs mappings remain active.
vim.keymap.set("i", "'", "'", { buffer = true, desc = "Insert single quote" })
