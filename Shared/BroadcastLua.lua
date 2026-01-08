local BROADCASTLUA = "BroadcastLua"

-- Server-side
if Server then
  function BroadcastLua(code)
    return Events.BroadcastRemote(BROADCASTLUA, code)
  end

  function Player.SendLua(player, code)
    return Events.CallRemote(BROADCASTLUA, player, code)
  end

  Package.Export(BROADCASTLUA, BroadcastLua)
  return
end

-- Client-side
Events.SubscribeRemote(BROADCASTLUA, function(code)
  local fn = load(code, BROADCASTLUA, "t")
  if type(fn) == "function" then
    pcall(fn)
  end
end)
