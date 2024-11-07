vim.api.nvim_set_keymap(
	"n",
	"<F6>",
	':lua vim.cmd("!bash ./build.sh " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<F7>",
	':lua vim.cmd("!bash ./build_test.sh " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))<CR>',
	{ noremap = true, silent = true }
)
