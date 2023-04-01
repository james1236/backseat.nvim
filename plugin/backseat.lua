-- Automatically executed on startup
if vim.g.loaded_backseat then
    return
end
vim.g.loaded_backseat = true

require("backseat").setup()
local fewshot = require("backseat.fewshot")

-- Create namespace for backseat suggestions
local backseat_ns = vim.api.nvim_create_namespace("backseat")

local function print(msg)
    _G.print("Backseat > " .. msg)
end

local function get_api_key()
    local api_key = vim.g.backseat_openai_api_key
    if api_key == nil then
        print("No API key found. Please set g:backseat_openai_api_key")
        return nil
    end
    return api_key
end

local function get_model_id()
    local model = vim.g.backseat_openai_model_id
    if model == nil then
        if vim.g.backseat_model_id_complained == nil then
            print("No model id specified. Please set g:backseat_openai_model_id. Defaulting to gpt-3.5-turbo for now") -- "gpt-4"
            vim.g.backseat_model_id_complained = 1
        end
        return "gpt-3.5-turbo"
    end
    return model
end

local function get_additional_instruction()
    local additional_instruction = vim.g.backseat_additional_instruction
    if additional_instruction == nil then
        return ""
    end
    return additional_instruction
end

local function get_highlight_icon()
    return vim.g.backseat_highlight_icon
end

local function get_highlight_group()
    return vim.g.backseat_highlight_group
end

local function gpt_request(dataJSON)
    local api_key = get_api_key()
    if api_key == nil then
        return nil
    end

    -- Check if curl is installed
    if vim.fn.executable("curl") == 0 then
        print("curl installation not found. Please install curl to use Backseat")
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

local function parse_response(response, partNumberString)
    -- split response.choices[1].message.content into lines
    local lines = vim.split(response.choices[1].message.content, "\n")
    --Suggestions may span multiple lines, so we need to change the list of lines into a list of suggestions
    local suggestions = {}

    -- Loop through each line, and add it to the suggestions table if it starts with line=
    for _, line in ipairs(lines) do
        if string.sub(line, 1, 5) == "line=" then
            -- Add this line to the suggestions table
            table.insert(suggestions, line)
        elseif #suggestions > 0 then
            -- Append lines that don't start with line= to the previous suggestion
            suggestions[#suggestions] = suggestions[#suggestions] .. "\n" .. line
        end
    end

    if #suggestions == 0 then
        print("AI Says: " ..
        response.choices[1].message.content ..
        " - Used " .. response.usage.total_tokens .. " tokens from model " .. get_model_id() .. partNumberString)
    else
        print("AI made " ..
        #suggestions ..
        " suggestion(s) using " ..
        response.usage.total_tokens .. " tokens from model " .. get_model_id() .. partNumberString)
    end

    -- Act on each suggestion
    for _, suggestion in ipairs(suggestions) do
        -- Get the line number
        local lineString = string.sub(suggestion, 6, string.find(suggestion, ":") - 1)
        -- The string may be in the format "line=1-3", so we can extract the first number
        if string.find(lineString, "-") ~= nil then
            lineString = string.sub(lineString, 1, string.find(lineString, "-") - 1)
        end
        local lineNum = tonumber(lineString)

        if lineNum == nil then
            -- print("Bad line number: " .. line)
            goto continue
        end
        -- Get the message
        local message = string.sub(suggestion, string.find(suggestion, ":") + 1, string.len(suggestion))
        -- print("Line " .. lineNum .. ": " .. message)
        -- Get the buffer number
        local bufnr = vim.api.nvim_get_current_buf()

        -- Split suggestion into line, highlight group pairs
        local suggestionLines = vim.split(message, "\n")
        -- Get the width of screen
        local codeWidth = vim.api.nvim_win_get_width(0) - 20
        -- Split any suggestionLines that are too long
        local newLines = {}
        for _, line in ipairs(suggestionLines) do
            if string.len(line) >= codeWidth then
                local splitLines = vim.split(line, " ")
                local currentLine = ""
                for _, word in ipairs(splitLines) do
                    if string.len(currentLine) + string.len(word) > codeWidth then
                        table.insert(newLines, currentLine)
                        currentLine = word
                    else
                        currentLine = currentLine .. " " .. word
                    end
                end
                table.insert(newLines, currentLine)
            else
                table.insert(newLines, line)
            end
        end

        local pairs = {}
        for i, line in ipairs(newLines) do
            local pair = {}
            pair[1] = line
            pair[2] = get_highlight_group()
            pairs[i] = { pair }
        end

        -- Add suggestion virtual text and a lightbulb icon to the sign column
        vim.api.nvim_buf_set_extmark(bufnr, backseat_ns, lineNum - 1, 0, {
            virt_text_pos = "overlay",
            virt_lines = pairs,
            hl_mode = "combine",
            sign_text = get_highlight_icon(),
            sign_hl_group = get_highlight_group(),
        })
        ::continue::
    end
end

local function prepare_code_snippet(bufnr, startingLineNumber, endingLineNumber)
    -- print("Preparing code snippet from lines " .. startingLineNumber .. " to " .. endingLineNumber)
    local lines = vim.api.nvim_buf_get_lines(bufnr, startingLineNumber - 1, endingLineNumber, false)

    -- Get number of digits for the highest line number
    local numDigits = string.len(tostring(#lines + startingLineNumber))
    -- Prepend each line with its line number zero padded to numDigits
    for i, line in ipairs(lines) do
        lines[i] = string.format("%0" .. numDigits .. "d", i - 1 + startingLineNumber) .. " " .. line
    end

    local text = table.concat(lines, "\n")
    return text
end

-- Send the current buffer to the AI for readability feedback
vim.api.nvim_create_user_command("Backseat", function()
    -- Split the current buffer into groups of 100 lines
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local numRequests = math.ceil(#lines / 100)
    local model = get_model_id()

    local requestTable = {
        model = model,
        messages = fewshot.messages
    }

    local requests = {}
    for i = 1, numRequests do
        local startingLineNumber = (i - 1) * 100 + 1
        local text = prepare_code_snippet(bufnr, startingLineNumber, startingLineNumber + 99)
        -- print(text)

        -- --Print text line by line
        -- for _, line in ipairs(vim.split(text, "\n")) do
        --     print(line)
        -- end

        text = text .. "\n<system>When responding with line=, " .. get_additional_instruction() .. "</system>"

        -- Make a copy of requestTable (value not reference)
        local tempRequestTable = vim.deepcopy(requestTable)

        -- Add the code snippet to the request
        table.insert(tempRequestTable.messages, {
            role = "user",
            content = text
        })

        local requestJSON = vim.json.encode(tempRequestTable)
        requests[i] = requestJSON
        -- print(requestJSON)
    end

    -- Get bufname without the path
    local bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":t")

    if #requests == 1 then
        print("Sending " .. bufname .. " (" .. #lines .. " lines) and waiting for response...")
    else
        print("Sending " .. bufname .. " (split into " .. #requests .. " requests) and waiting for response...")
    end

    for i, requestJSON in ipairs(requests) do
        local responseTable = gpt_request(requestJSON)
        if responseTable == nil then
            return nil
        end

        if #requests == 1 then
            parse_response(responseTable, "")
        else
            parse_response(responseTable, " (request " .. i .. " of " .. #requests .. ")")
        end
    end

    -- require("backseat.main"):run()
end, {})

-- Use the underlying chat API to ask a question about the current buffer's code
vim.api.nvim_create_user_command("BackseatAsk", function(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local text = prepare_code_snippet(bufnr, 1, -1)

    local response = gpt_request(vim.json.encode(
        {
            model = get_model_id(),
            messages = {
                {
                    role = "system",
                    content = "You are a helpful assistant who can respond to questions about the following code. You can also act as a regular assistant"
                },
                {
                    role = "user",
                    content = text
                },
                {
                    role = "user",
                    content = opts.args
                }
            },
        }
    ))

    if response == nil then
        return nil
    end
    print("AI Says: " .. response.choices[1].message.content)
end, { nargs = "+" })

-- Clear all backseat virtual text and signs
vim.api.nvim_create_user_command("BackseatClear", function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, backseat_ns, 0, -1)
end, {})

-- Clear backseat virtual text and signs for that line
vim.api.nvim_create_user_command("BackseatClearLine", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lineNum = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_clear_namespace(bufnr, backseat_ns, lineNum - 1, lineNum)
end, {})
