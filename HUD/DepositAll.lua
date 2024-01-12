local MESSAGES_DEPOSIT = {
    "hi",
    "deposit all",
    "yes"
}

function depositAll()
    Client.showMessage("Depositando...")
    for _, message in ipairs(MESSAGES_DEPOSIT) do
        Game.talk(message, 12)
        wait(450)
    end
end