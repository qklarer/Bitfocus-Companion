debug = true

--Sets LED Connect light.
function Response(Table, ReturnCode, Data, Error, Headers)

    if debug then
        print(ReturnCode)
        print(Data)
        print(Table)
        print(Error)
        print(Headers)
    end

    if (200 == ReturnCode or ReturnCode == 201) then
        NamedControl.SetValue('LED #1', 1)
    else
        NamedControl.SetValue('LED #1', 0)
    end
end

--Uploads the URL with the assosiated "Bank" or button as well as the page.
function Press_Button(Page, Bank, IP, Port)

    HttpClient.Upload({
        Url = "http://" .. IP .. ":" .. Port .. "/press/bank/" .. Page .. "/" .. Bank,
        Data = "",
        Method = "GET",
        EventHandler = Response })
end

--Removes trailing 0's from Intelligent Module for Bitcompanion.
function Format(Input)

    Formatted_Page = string.gsub(Input, ".0", "")
    return Formatted_Page
end

function TimerClick()

    local IP = NamedControl.GetText("IP")
    local Port = NamedControl.GetText("Port")
    local Page = NamedControl.GetValue("Page")
    local offlineConnectButton = NamedControl.GetValue("OfflineConnect")

    --Establishes if allowed to connect.
    if offlineConnectButton == 1 and Device.Offline then
        allowConnect = true
    elseif Device.Offline == false then
        allowConnect = true
    else
        allowConnect = false
    end

    if allowConnect then

        if NamedControl.GetPosition("Page Up") == 1 then
            Page = Page + 1

            if Page == 100 then --Limits pages to max of 99.
                Page = 1
            end

            NamedControl.SetValue("Page", Page)
            NamedControl.SetPosition("Page Up", 0)
        end

        if NamedControl.GetPosition("Page Down") == 1 then
            Page = Page - 1

            if Page == 0 then --Limits pages to min of 0.
                Page = 99
            end

            NamedControl.SetValue("Page", Page)
            NamedControl.SetPosition("Page Down", 0)
        end

        for i = 1, 32 do
            --checks all 32 buttons on the current page for position.
            if NamedControl.GetPosition("b" .. i) == 1 then
                --Gets current page selected.
                Press_Button(Format(Page), i, IP, Port)
                NamedControl.SetPosition("b" .. i, 0)
            end
        end
    end
end

MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(.50)
