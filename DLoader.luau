local BaseUrl = "https://raw.githubusercontent.com/smthneededyk/Abysall/refs/heads/main/"
if game.PlaceId ~= 6516141723 then
    loadstring(game:HttpGet(BaseUrl .. "DMain.luau"))()
else
    loadstring(game:HttpGet(BaseUrl .. "DLobby.luau"))()
end
