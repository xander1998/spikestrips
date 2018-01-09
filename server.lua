RegisterCommand("setspikes", function(source, args, string)
    local s = source
    local cm = stringsplit(string, " ")
    local amount = tonumber(cm[2])

    if type(amount) == "number" then
        if amount <= SpikeConfig.MaxSpikes then
            TriggerClientEvent("Spikestrips:SpawnSpikes", s, {
                isRestricted = SpikeConfig.PedRestriction,
                pedList = SpikeConfig.PedsList,
            }, amount)
        else
            print("You can not spawn that many spike strips")
        end
    end
end, false)

RegisterCommand("deletespikes", function(source, args, string)
    local s = source
    TriggerClientEvent("Spikestrips:RemoveSpikes", s)
end, false)

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end