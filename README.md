# backseat.nvim
A neovim plugin that uses GPT to highlight and explain code readability issues. Get unsolicited advice of dubious quality in never-before-seen quantities!
<br><br>
![image](https://user-images.githubusercontent.com/32351696/229314187-f229664f-f396-4840-9765-8118810b3dae.png)

# Commands
| User Command | Purpose |
| -- | -- |
| `:Backseat`  | Sends the current buffer to OpenAI to highlight readability feedback |
| `:BackseatAsk <question>` | Ask a question about the code in the current buffer (i.e What does the function on line 20 do?, Summarize this code)
| `:BackseatClear` | Clear all Backseat highlighting from the current buffer
| `:BackseatClearLine` | Clear the current line of Backseat highlighting

If a buffer contains more than 100 lines, it will be split into multiple <= 100 line requests.
## Requirements
 * curl
 * OpenAI API key - You can get yours with a free account from [their website](https://platform.openai.com/account/api-keys). If you don't have any more free credits, usage is very cheap at ~$0.004 per 100 lines submitted.
# Install
### Lazy plugin manager
```lua
{
    "james1236/backseat.nvim",
    config = function()
        require("backseat").setup({
            -- Alternatively, set the env var $OPENAI_API_KEY by putting "export OPENAI_API_KEY=sk-xxxxx" in your ~/.bashrc
            openai_api_key = 'sk-xxxxxxxxxxxxxx', -- Get yours from platform.openai.com/account/api-keys
            openai_model_id = 'gpt-3.5-turbo', --gpt-4 (If you do not have access to a model, it says "The model does not exist")
            openai_languages = 'english', -- Set reply language
            -- split_threshold = 100,
            -- additional_instruction = "Respond snarkily", -- (GPT-3 will probably deny this request, but GPT-4 complies)
            -- highlight = {
            --     icon = '', -- ''
            --     group = 'Comment',
            -- }
        })
    end
},
```
### The result of using `additional_instruction = "Respond snarkily"`
![image](https://user-images.githubusercontent.com/32351696/229297495-6d145848-10bf-43eb-8c2a-ab4264f514b1.png)

# Config 
| Setup Table Name | Default | Purpose |
| --- | --- | -- |
| `openai_api_key` | `nil` | Your OpenAI API key, needed to use their language models
| `openai_model_id` | `'gpt-3.5-turbo'` | The model's identifier, such as gpt-3.5-turbo and gpt-4
| `split_threshold` | `100` | The max number of lines of code sent per request (lower uses more tokens but increases number of suggestions)
| `additional_instruction`, | `nil` | An additional instruction to give the AI, like "Make your responses more brief"
| `highlight.icon` | `''` | The sign column icon to display for each line containing suggestions
| `highlight.group` | `'String'` | The `:hi` highlight color group for the icon and the suggestion text 

# More Examples
![image](https://user-images.githubusercontent.com/32351696/229299250-1fcb4135-2a6a-4663-9637-13af7c0ee7cd.png)
