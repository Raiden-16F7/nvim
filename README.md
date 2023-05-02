# 💤 LazyVim config 

A config based off of LazyVim with Tabnine and ChatGPT support.
Just copy my config to your nvim path and run

    nvim

Default theme is set to catppuccin.

To make Tabnine work on windows, you need to perform the following:
## Installation
### Linux
Backup Your previous configuration

    mv ~/.config/nvim ~/.config/nvim.bak
    mv ~/.local/share/nvim ~/.local/share/nvim.bak
    mv ~/.local/state/nvim ~/.local/state/nvim.bak
    mv ~/.cache/nvim ~/.cache/nvim.bak

Run the following command

    git clone https://github.com/LazyVim/starter ~/.config/nvim

### Windows
Backup your previous Configuration

    # required
    Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak
    # optional but recommended
    Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak

Run the following command

    git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim

## Configuration
### Windows

<!-- > **Note:**
> For Please see below for Windows installation instructions -->

The build script needs a set execution policy.
Here is an example on how to set it

```Powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

For more information visit
[the official documentation](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.2)

Windows installations need to be adjusted to utilize PowerShell. This can be accomplished by changing the `do`/`run`/`build` parameter in your plugin manager's configuration from `./dl_binaries.sh` to `pwsh.exe -file .\\dl_binaries.ps1`

```Lua
-- Example using lazy.nvim
-- pwsh.exe for PowerShell Core
-- powershell.exe for Windows PowerShell

require("lazy").setup({
  { 'codota/tabnine-nvim', build = "pwsh.exe -file .\\dl_binaries.ps1" },
})
```

If you need to use Tabnine on Windows and Unix you can change the config as follows

```lua
-- Get platform dependant build script
local function tabnine_build_path()
  if vim.loop.os_uname().sysname == "Windows_NT" then
    return "pwsh.exe -file .\\dl_binaries.ps1"
  else
    return "./dl_binaries.sh"
  end
end
require("lazy").setup({
  { 'codota/tabnine-nvim', build = tabnine_build_path()},
})
```

---

### ChatGPT
For ChatGPT to work you need to set the API-Key in your environment path.
#### For Linux
      export OPENAI_API_KEY = "Your OPENAI_API_KEY"

#### For Windows
Press windows key and search for environment variables
Then edit your path variable 
Add a new variable called OPENAI_API_KEY.

#### Note
Feel free to edit this config to your liking and refer me.
