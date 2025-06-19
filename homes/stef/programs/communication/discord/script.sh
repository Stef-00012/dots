current_workspace=$(hyprctl activewindow -j | jq -r ".workspace.name")
discord_workspace=$(hyprctl clients -j | jq -r '.[] | select(.class=="chrome-discord.com__app-Default") | .workspace.name')

if [ -z "$discord_workspace" ]; then
    chromium --app=https://discord.com/app
    exit 1
fi

if [ "$current_workspace" != "$discord_workspace" ]; then
    hyprctl dispatch focuswindow "class:^(chrome-discord.com__app-Default)$"
fi