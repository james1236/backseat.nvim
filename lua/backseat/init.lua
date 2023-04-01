local M = {}

local default_opts = {
    openai_api_key = nil,
    openai_model_id = 'gpt-3.5-turbo',
    additional_instruction = nil,
    highlight = {
        icon = '',
        group = 'String',
    }
}

function M.setup(opts)
    -- Merge default_opts with opts
    opts = vim.tbl_deep_extend('force', default_opts, opts or {})

    -- Set the module's options
    if vim.g.backseat_openai_api_key == nil then
        vim.g.backseat_openai_api_key = opts.openai_api_key
    end

    if vim.g.backseat_openai_model_id == nil then
        vim.g.backseat_openai_model_id = opts.openai_model_id
    end

    if vim.g.backseat_additional_instruction == nil then
        vim.g.backseat_additional_instruction = opts.additional_instruction
    end

    if vim.g.backseat_highlight_icon == nil then
        vim.g.backseat_highlight_icon = opts.highlight.icon
    end

    if opts.backseat_highlight_group == nil then
        vim.g.backseat_highlight_group = opts.highlight.group
    end
end

return M
