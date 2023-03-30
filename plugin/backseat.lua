-- Automatically executed on startup
if vim.g.loaded_backseat then
    return
end
vim.g.loaded_backseat = true

-- vim.api.nvim_get_current_buf()
-- vim.api.nvim_buf_get_lines(bufnr, start, end, strict_indexing)

require("backseat").setup()

-- local http = require("http")

local request_data = {
    model = "gpt-3.5-turbo",
    messages = { {
        role = "user",
        content = "Hello!"
    } },
}

local function gpt_request(data, api_key)
    local curlRequest = string.format(
        "curl -s https://api.openai.com/v1/chat/completions -H \"Content-Type: application/json\" -H \"Authorization: Bearer " ..
        api_key .. "\" -d '" .. data .. "'"
    )
    print(curlRequest)

    local response = vim.fn.system(curlRequest)
    local responseTable = vim.fn.json_decode(response)

    print(response)
    return responseTable
end

local function parseResponse(response)

end

vim.api.nvim_create_user_command("BackseatAuthKey", function(opt)
    -- local bufnr = tonumber(opt.args)
    -- require("ccc.highlighter"):enable(bufnr)
end, { nargs = "?" })

vim.api.nvim_create_user_command("Backseat", function()
    print("Backseat setup: " .. vim.inspect(vim.g.loaded_backseat))

    local request = vim.fn.json_encode(request_data)
    -- local response = gpt_request(request, vim.g.openai_api_key)

    local response = vim.fn.json_decode([[
    {
      "id": "chatcmpl-<id>",
      "object": "chat.completion",
      "created": 1680192412,
      "model": "gpt-3.5-turbo-0301",
      "usage": {
        "prompt_tokens": 10,
        "completion_tokens": 9,
        "total_tokens": 19
      },
      "choices": [
        {
          "message": {
            "role": "assistant",
            "content": "Hello! How can I assist you today?"
          },
          "finish_reason": "stop",
          "index": 0
        }
      ]
    }]])

    parseResponse(response)

    -- require("backseat.main"):run()
end, {})
