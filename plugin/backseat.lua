-- Automatically executed on startup
if vim.g.loaded_backseat then
    return
end
vim.g.loaded_backseat = true

-- vim.api.nvim_get_current_buf()
-- vim.api.nvim_buf_get_lines(bufnr, start, end, strict_indexing)

require("backseat").setup()

-- local http = require("http")

local requestData = {
    model = "gpt-3.5-turbo",
    messages = { {
        role = "user",
        content = "What are some code readability tips?"
    } },
}

local function print(msg)
    _G.print("Backseat > " .. msg)
end

local function gpt_request(dataJSON, api_key)
    if api_key == nil then
        print("No API key found. Please set g:openai_api_key")
        return nil
    end

    local curlRequest = string.format(
        "curl -s https://api.openai.com/v1/chat/completions -H \"Content-Type: application/json\" -H \"Authorization: Bearer " ..
        api_key .. "\" -d '" .. dataJSON .. "'"
    )
    -- print(curlRequest)

    local response = vim.fn.system(curlRequest)
    local success, responseTable = pcall(vim.json.decode, response)

    if success == false or responseTable == nil then
        print("Bad or no response: " .. response)
        return nil
    end

    if responseTable.error ~= nil then
        print("OpenAI Error: " .. responseTable.error.message)
        return nil
    end

    -- print(response)
    return responseTable
end

local function parseResponse(response)
    print("AI Says: " .. response.choices[1].message.content)
end

-- vim.api.nvim_create_user_command("BackseatAuthKey", function(opt)
--     -- local bufnr = tonumber(opt.args)
--     -- require("ccc.highlighter"):enable(bufnr)
-- end, { nargs = "?" })

vim.api.nvim_create_user_command("Backseat", function()
    -- print("Backseat setup: " .. vim.inspect(vim.g.loaded_backseat))

    local requestJSON = vim.json.encode(requestData)
    local responseTable = gpt_request(requestJSON, vim.g.openai_api_key)
    if responseTable == nil then
        return nil
    end

    -- local response = vim.fn.json_decode([[
    -- {
    --   "id": "chatcmpl-<id>",
    --   "object": "chat.completion",
    --   "created": 1680192412,
    --   "model": "gpt-3.5-turbo-0301",
    --   "usage": {
    --     "prompt_tokens": 10,
    --     "completion_tokens": 9,
    --     "total_tokens": 19
    --   },
    --   "choices": [
    --     {
    --       "message": {
    --         "role": "assistant",
    --         "content": "Hello! How can I assist you today?"
    --       },
    --       "finish_reason": "stop",
    --       "index": 0
    --     }
    --   ]
    -- }]])

    parseResponse(responseTable)

    -- require("backseat.main"):run()
end, {})
