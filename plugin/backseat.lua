-- Automatically executed on startup
if vim.g.loaded_backseat then
    return
end
vim.g.loaded_backseat = true

require("backseat").setup()
local fewshot = require("backseat.fewshot")

-- Create a namespace
local backseat_ns = vim.api.nvim_create_namespace("backseat")

local model = "gpt-4" -- gpt-3.5-turbo

local function print(msg)
    _G.print("Backseat > " .. msg)
end

local function getAPIKey()
    local api_key = vim.g.openai_api_key
    if api_key == nil then
        print("No API key found. Please set g:openai_api_key")
        return nil
    end
    return api_key
end

local function gpt_request(dataJSON)
    local api_key = getAPIKey()
    if api_key == nil then
        return nil
    end

    -- Convert dataJSON to a hex string using string.byte so that it can be passed without escaping issues
    local dataHex = ""
    for i = 1, #dataJSON do
        local hex = string.format("%02x", string.byte(dataJSON, i))
        dataHex = dataHex .. "\\x" .. hex
    end

    local curlRequest = string.format(
        "echo -en '" ..
        dataHex ..
        "' | curl -s https://api.openai.com/v1/chat/completions -H \"Content-Type: application/json\" -H \"Authorization: Bearer " ..
        api_key .. "\" --data-binary @-"
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
    -- split response.choices[1].message.content into lines
    local lines = vim.split(response.choices[1].message.content, "\n")
    for _, line in ipairs(lines) do
        -- If line starts with line=
        if string.sub(line, 1, 5) == "line=" then
            -- Get the line number
            local lineNum = tonumber(string.sub(line, 6, string.find(line, ":") - 1))
            if lineNum == nil then
                print("Bad line number: " .. line)
                goto continue
            end
            -- Get the message
            local message = string.sub(line, string.find(line, ":") + 1, string.len(line))
            -- Print the message
            print("Line " .. lineNum .. ": " .. message)
            -- Get the buffer number
            local bufnr = vim.api.nvim_get_current_buf()
            -- Add a lightbulb icon to the end of the line
            -- vim.api.nvim_buf_set_extmark(bufnr, backseat_ns, lineNum - 1, 0, { virt_text = { { "", "Comment" } } })
            -- Add a lightbulb icon to the line number column
            vim.api.nvim_buf_set_extmark(bufnr, backseat_ns, lineNum - 1, 0, {
                virt_text = { { "", "Backseat" } },
                virt_text_pos = "overlay",
                hl_mode = "combine",
            })
            ::continue::
        end
    end
end

-- Set up the API key
-- vim.api.nvim_create_user_command("BackseatAuthKey", function(opt)
--     -- local bufnr = tonumber(opt.args)
--     -- require("ccc.highlighter"):enable(bufnr)
-- end, { nargs = "?" })

-- Use the underlying chat API to ask a question about the current buffer's code
vim.api.nvim_create_user_command("BackseatAsk", function(opts)
    local response = gpt_request(vim.json.encode(
        {
            model = model,
            messages = { {
                role = "user",
                content = opts.args
            } },
        }
    ))

    if response == nil then
        return nil
    end
    print("AI Says: " .. response.choices[1].message.content)
end, {})

-- Send the current buffer to the AI for readability feedback
vim.api.nvim_create_user_command("Backseat", function()
    -- print("Backseat setup: " .. vim.inspect(vim.g.loaded_backseat))

    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local startingLineNumber = 1

    -- Get number of digits for the highest line number
    local numDigits = string.len(tostring(#lines + startingLineNumber))
    -- Prepend each line with its line number zero padded to numDigits
    for i, line in ipairs(lines) do
        lines[i] = string.format("%0" .. numDigits .. "d", i) .. " " .. line
    end

    local text = table.concat(lines, "\n")

    local requestTable = {
        model = model,
        messages = fewshot.messages
    }

    -- Add the current buffer to the request
    table.insert(requestTable.messages, {
        role = "user",
        content = text
    })

    local requestJSON = vim.json.encode(requestTable)

    -- Get bufname without the path
    local bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":t")
    print("Sending " .. bufname .. " and waiting for response...")

    local responseTable = gpt_request(requestJSON)
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
