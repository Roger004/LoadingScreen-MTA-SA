local screenWidth, screenHeight = guiGetScreenSize()
local isDrawing = false
local soundtracks = nil 
local nombretrack = nil

local loadingTips = {
    {"Nivel de rol", "Jugarás en un servidor de rol serio, tu nivel de rol debe mantenerse en lo más alto y sobre todo debes\nrespetar las normativas para evitar ser sancionado/a. Recuerda que las sanciones se acumulan y pueden\nconvertirse en baneos."},
    {"Elige tu camino", "Lo ideal es que ya tengas planificada una trama para tu personaje, así sabrás cuales son los caminos que\nel mismo tomará. ¿Será una persona de negocios y buena reputación o se dejará llevar por la idea\nde ganar dinero fácil en el mundo ilegal?."},
    -- Puedes añadir más tips/consejos acá.
}

local currentTipIndex = 1
local tipChangeTimer = nil
local loadingSpinner = "."

local FAKE_LOADING_DURATION = 8000 
local loadingMode = nil 
local fakeLoadingStartTime = getTickCount()

local totalFilesToDownload = 0
local filesDownloaded = 0
local currentFileName = ""
local overallProgress = 0

local currentColorR, currentColorG, currentColorB = 255, 255, 255
local targetColorR, targetColorG, targetColorB = math.random(0, 255), math.random(0, 255), math.random(0, 255)
local transitionSpeed = 0.100


local function rgbToHex(r, g, b)
    -- Ensure input values are within the valid range (0-255)
    r = math.max(0, math.min(255, r))
    g = math.max(0, math.min(255, g))
    b = math.max(0, math.min(255, b))

    -- Format each component as a two-digit hexadecimal number
    -- and concatenate them with a '#' prefix
    return string.format("#%02X%02X%02X", r, g, b)
end

local playlist = {
    {"https://eu1.lhdserver.es:9019/stream", "La Revoltosa"},
    {"https://node-13.zeno.fm/gqw62kfvbrruv?rj-ttl=5&rj-tok=AAABcskGnS8AMlTQf2BgP3vY6w", "Actuality FM"},
    {"http://provisioning.streamtheworld.com/pls/LOS40.pls", "Los 40"},
}

function updateLoadingText()
    currentTipIndex = currentTipIndex + 1
    if currentTipIndex > #loadingTips then
        currentTipIndex = 1
    end
end

function updateLoadingSpinner()
    if loadingSpinner == "." then loadingSpinner = ".."
    elseif loadingSpinner == ".." then loadingSpinner = "..."
    else loadingSpinner = "." end
end

local function renderLoadingScreen()
    if not isDrawing then return end 

    currentColorR = currentColorR + (targetColorR - currentColorR) * transitionSpeed
    currentColorG = currentColorG + (targetColorG - currentColorG) * transitionSpeed
    currentColorB = currentColorB + (targetColorB - currentColorB) * transitionSpeed

   
    if (math.abs(currentColorR - targetColorR) < 1 and
        math.abs(currentColorG - targetColorG) < 1 and
        math.abs(currentColorB - targetColorB) < 1) then
        
        targetColorR = math.random(0, 255)
        targetColorG = math.random(0, 255)
        targetColorB = math.random(0, 255)
    end

    local radioColor = rgbToHex(math.floor(currentColorR), math.floor(currentColorG), math.floor(currentColorB))

    dxDrawRectangle(screenWidth * 0.0000, screenHeight * 0.0000, screenWidth * 1.0000, screenHeight * 0.0839, tocolor(0, 0, 0, 230), false)
    dxDrawRectangle(screenWidth * 0.0000, screenHeight * 0.7961, screenWidth * 1.0000, screenHeight * 0.2639, tocolor(0, 0, 0, 230), false)
    
    dxDrawText("En sintonía: "..nombretrack.." ♫", (screenWidth / 2) - 1, (screenHeight * 0.02) - 1, screenWidth / 2, screenHeight * 0.5, tocolor(0, 0, 0, 255), 1.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText("En sintonía: "..nombretrack.." ♫", (screenWidth / 2) + 1, (screenHeight * 0.02) - 1, screenWidth / 2, screenHeight * 0.5, tocolor(0, 0, 0, 255), 1.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText("En sintonía: "..nombretrack.." ♫", (screenWidth / 2) - 1, (screenHeight * 0.02) + 1, screenWidth / 2, screenHeight * 0.5, tocolor(0, 0, 0, 255), 1.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText("En sintonía: "..nombretrack.." ♫", (screenWidth / 2) + 1, (screenHeight * 0.02) + 1, screenWidth / 2, screenHeight * 0.5, tocolor(0, 0, 0, 255), 1.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText(radioColor.."En sintonía#FFFFFF: "..nombretrack.." ♫", (screenWidth / 2), screenHeight * 0.02, screenWidth / 2, screenHeight * 0.5, tocolor(255, 255, 255, 255), 1.00, "default-bold", "center", "top", false, false, false, true, false)


    dxDrawImage(screenWidth * 0.487, screenHeight * 0.8185, screenWidth * 0.025, screenHeight * 0.030, 'files/idea.png', 0, 0, 0, tocolor(255, 255, 255, 195))
    dxDrawText(loadingTips[currentTipIndex][1], (screenWidth * 0.2833) - 1, (screenHeight * 0.8617) - 1, (screenWidth * 0.7167) - 1, (screenHeight * 0.8370) - 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][1], (screenWidth * 0.2833) + 1, (screenHeight * 0.8617) - 1, (screenWidth * 0.7167) + 1, (screenHeight * 0.8370) - 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][1], (screenWidth * 0.2833) - 1, (screenHeight * 0.8617) + 1, (screenWidth * 0.7167) - 1, (screenHeight * 0.8370) + 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][1], (screenWidth * 0.2833) + 1, (screenHeight * 0.8617) + 1, (screenWidth * 0.7167) + 1, (screenHeight * 0.8370) + 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][1], screenWidth * 0.2833, screenHeight * 0.8617, screenWidth * 0.7167, screenHeight * 0.8370, tocolor(255, 255, 255, 255), 2.00, "default-bold", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][2], (screenWidth * 0.2833) - 1, (screenHeight * 0.9063) - 1, (screenWidth * 0.7167) - 1, (screenHeight * 0.9815) - 1, tocolor(0, 0, 0, 255), 1.25, "default", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][2], (screenWidth * 0.2833) + 1, (screenHeight * 0.9063) - 1, (screenWidth * 0.7167) + 1, (screenHeight * 0.9815) - 1, tocolor(0, 0, 0, 255), 1.25, "default", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][2], (screenWidth * 0.2833) - 1, (screenHeight * 0.9063) + 1, (screenWidth * 0.7167) - 1, (screenHeight * 0.9815) + 1, tocolor(0, 0, 0, 255), 1.25, "default", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][2], (screenWidth * 0.2833) + 1, (screenHeight * 0.9063) + 1, (screenWidth * 0.7167) + 1, (screenHeight * 0.9815) + 1, tocolor(0, 0, 0, 255), 1.25, "default", "center", "top", false, false, false, false, false)
    dxDrawText(loadingTips[currentTipIndex][2], screenWidth * 0.2833, screenHeight * 0.9063, screenWidth * 0.7167, screenHeight * 0.9815, tocolor(255, 255, 255, 255), 1.25, "default", "center", "top", false, false, false, false, false)

    local barW = screenWidth * 0.2 
    local barH = 25
    local barX = (screenWidth - barW) / 2
    local barY = screenHeight * 0.045

    local statusText = ""

    if loadingMode == "real" then
        local elapsedTime = getTickCount() - fakeLoadingStartTime
        overallProgress = math.min(1, elapsedTime / FAKE_LOADING_DURATION) 
        if overallProgress == 1.0 then
            overallProgress = 0 
            fakeLoadingStartTime = getTickCount()
        end
        statusText = "Descargando recursos" .. loadingSpinner
    elseif loadingMode == "fake" then
        local elapsedTime = getTickCount() - fakeLoadingStartTime
        overallProgress = math.min(1, elapsedTime / FAKE_LOADING_DURATION) 
        statusText = "Cargando los recursos" .. loadingSpinner
    end

    -- barra de progreso
    dxDrawRectangle(barX, barY, barW, barH, tocolor(0, 0, 0, 150)) 
    dxDrawRectangle(barX, barY, barW * overallProgress, barH, tocolor(20, 150, 255, 200)) 
    dxDrawText(statusText, barX - 1.1, barY - 1.1, barX + barW, barY + barH, tocolor(0, 0, 0, 255), 1.25, "default-bold", "center", "center")
    dxDrawText(statusText, barX + 1.1, barY - 1.1, barX + barW, barY + barH, tocolor(0, 0, 0, 255), 1.25, "default-bold", "center", "center")
    dxDrawText(statusText, barX - 1.1, barY + 1.1, barX + barW, barY + barH, tocolor(0, 0, 0, 255), 1.25, "default-bold", "center", "center")
    dxDrawText(statusText, barX + 1.1, barY + 1.1, barX + barW, barY + barH, tocolor(0, 0, 0, 255), 1.25, "default-bold", "center", "center")
    dxDrawText(statusText, barX, barY, barX + barW, barY + barH, tocolor(255, 255, 255, 255), 1.25, "default-bold", "center", "center")
end

contador = 1
c = nil
timerCamera = nil
timer2 = nil
movimiento = 0
limite = 12
cords = { -- Estas son las escenas mostradas en la pantalla de carga
    {1255.3559570312, -1467.5550537109, 35.050228118896, 1189.9422607422, -1395.4031982422, 12.352850914001}, 
    {1028.8699951172, -1717.96875, 30.436235427856, 1097.5317382812, -1650.7763671875, 2.6739101409912}, 
    {317.93316650391, -2027.6463623047, 27.700300216675, 406.07299804688, -2066.2250976562, 0.44127431511879}, 
    {1974.3142089844, -1867.9849853516, 25.211696624756, 1918.5347900391, -1788.7990722656, 0.34730020165443},
    {2717.0881347656, -1894.8599853516, 41.251560211182, 2722.8500976562, -1801.4908447266, 5.9104514122009}, 
    {2064.0324707031, -1763.6882324219, 27.155374526978, 2137.5366210938, -1816.4602050781, -15.415046691895},
    {662.99285888672, -616.19860839844, 31.101663589478, 585.74694824219, -564.53625488281, -5.8315997123718}, 
    {1325.3430175781, -1130.3356933594, 43.311096191406, 1412.6782226562, -1084.7099609375, 26.256450653076},
    {1887.3546142578, 129.06163024902, 47.440841674805, 1962.7651367188, 191.40501403809, 26.78763961792}, 
    {2380.9750976562, 68.693794250488, 35.595699310303, 2456.0510253906, 128.15870666504, 6.829071521759},  
    {545.74481201172, 817.08587646484, -14.505048751831, 626.12084960938, 862.34429931641, -53.123279571533},   
}

function movement()
    movimiento = movimiento + 0.02
    c = setCameraMatrix(cords[contador][1], cords[contador][2]+movimiento, cords[contador][3], cords[contador][4]+movimiento, cords[contador][5], cords[contador][6])
end

function iniciarTimer()
    fadeCamera(true, 2.0)
    setCameraInterior(0)
    setElementInterior(localPlayer, 0)
    timerCamera = setTimer(function() 
        if contador + 1 < limite then
            fadeCamera(false, 0.5)
            timer2 = setTimer(function()
                contador = contador + 1
                movimiento = 0
                fadeCamera(true, 2.0)
            end, 800, 1)
        else
            fadeCamera(false, 0.5)
            timer2 = setTimer(function()
                fadeCamera(true, 2.0) 
                contador = 1
                movimiento = 0
            end, 800, 1)
        end                 
    end, 30000, 0)
end

function cameras()
    addEventHandler("onClientRender", root, movement) 
    iniciarTimer()
end
addEvent("onCameras", true)
addEventHandler("onCameras", getRootElement(), cameras)

function destroyCameras()
    if isTimer(timerCamera) then killTimer(timerCamera) end
    if isTimer(timer2) then killTimer(timer2) end
    c = nil
    timerCamera = 0
    contador = 1 
    removeEventHandler("onClientRender", root, movement) 
end 
addEvent("offCameras", true)
addEventHandler("offCameras", getRootElement(), destroyCameras)

local checkTimer = nil 

function stopLoadingScreen()
    if isDrawing then
        if isTimer(checkTimer) then
            killTimer(checkTimer)
            checkTimer = nil
        end
        if isTimer(tipChangeTimer) then
            killTimer(tipChangeTimer)
            tipChangeTimer = nil
        end
        if isTimer(tipChangeTimer2) then
            killTimer(tipChangeTimer2)
            tipChangeTimer2 = nil
        end
        isDrawing = false
        removeEventHandler('onClientRender', getRootElement(), renderLoadingScreen)
        setTransferBoxVisible(true)

        -- ACÁ DEBES LLAMAR A LA FUNCIÓN QUE MUESTRA TU PANEL DE LOGIN.
        -- triggerEvent("login.showLoginPanel", localPlayer) -- Este es un ejemplo

        -- Esto puedes eliminarlo si quieres que tu panel de login siga mostrando las escenas, pero deberas llamar al evento de destruir camaras para cancelar esas escenas luego.
        -- Lo mismo con la música.
        destroyCameras() 
        offSound()
    end
end

function checkDownloadStatus()
    if loadingMode == "real" then
        if (filesDownloaded == totalFilesToDownload) then
            --stopLoadingScreen()
        end
    elseif loadingMode == "fake" then
        if (getTickCount() - fakeLoadingStartTime >= FAKE_LOADING_DURATION) then
           --stopLoadingScreen()
        end
    end
end

function onSoundStopped(reason) 
    if isElement(soundtracks) then
        destroyElement(soundtracks)
    end
    onSound() 
end

function onSound()
    if not isElement(soundtracks) then
        local targetVolume = 0.30
        local duration = 5000
        local elapsedTime = 0
        math.randomseed(os.time())
        local random = math.random(1, #playlist)
        soundtracks = playSound(playlist[random][1], false)
        nombretrack = playlist[random][2]
        bool = true                      
        setSoundVolume(soundtracks, 0)        
        local function increaseVolume()
            if bool == true then
                elapsedTime = elapsedTime + 50
                local volume = (elapsedTime / duration) * targetVolume

                setSoundVolume(soundtracks, volume)

                if volume >= targetVolume then
                    setSoundVolume(soundtracks, targetVolume) 
                else
                    setTimer(increaseVolume, 50, 1) 
                end
            end
        end
        setTimer(increaseVolume, 50, 1) 
        addEventHandler("onClientSoundStopped", soundtracks, onSoundStopped)
    end
end
addEvent("onSound", true)
addEventHandler("onSound", getRootElement(), onSound)

function offSound()
    if isElement(soundtracks) then
        local currentVolume = getSoundVolume(soundtracks)  
        local duration = 3000 
        local elapsedTime = 0 
        bool = false
        local function decreaseVolume()
            elapsedTime = elapsedTime + 50 
            local volume = (1 - elapsedTime / duration) * currentVolume
            
            if isElement(soundtracks) then setSoundVolume(soundtracks, volume) end 
            
            if currentVolume <= 0 then
                if isElement(soundtracks) then stopSound(soundtracks) end
                if isElement(soundtracks) then destroyElement(soundtracks) end
                soundtracks = nil
                nombretrack = nil
                return                
            end     
            if elapsedTime < duration then
                setTimer(decreaseVolume, 50, 1) 
            else
                if isElement(soundtracks) then stopSound(soundtracks) end
                if isElement(soundtracks) then destroyElement(soundtracks) end
                soundtracks = nil
                nombretrack = nil    
            end         
        end     
        removeEventHandler("onClientSoundStopped", soundtracks, onSoundStopped)
        setTimer(decreaseVolume, 50, 1) 
    end
end
addEvent("offSound", true)
addEventHandler("offSound", getRootElement(), offSound)

function startLoadingScreen()
    if isDrawing then return end 
    isDrawing = true

    fadeCamera(true)
    setPlayerHudComponentVisible("all", false)
    setPlayerHudComponentVisible("crosshair", true)
        
    setWorldSoundEnabled(0, 0, false, false) -- Acá desactivo varios sonidos por defecto del gta:sa, como el de disparos y otras ambientaciones.
    setWorldSoundEnabled(0, 29, false, true)
    setWorldSoundEnabled(0, 30, false, true)
    setWorldSoundEnabled(5, false)   
    setWorldSoundEnabled(4, 1, false )
    setWorldSoundEnabled(4, 4, false )   
    for i, v in ipairs(getElementsByType("player")) do -- Acá desactivo las voces de los peds.
        setPedVoice(v, "PED_TYPE_DISABLED")
    end
    for i, v in ipairs(getElementsByType("ped")) do
        setPedVoice(v, "PED_TYPE_DISABLED")
    end
    setTransferBoxVisible(false)
    onSound()
    addEventHandler('onClientRender', getRootElement(), renderLoadingScreen)
    
    
    if isTransferBoxActive() then
        loadingMode = "real"
    else
        loadingMode = "fake"
        fakeLoadingStartTime = getTickCount()
    end

    checkTimer = setTimer(checkDownloadStatus, 500, 0) 
    tipChangeTimer = setTimer(updateLoadingText, 30500, 0) 
    tipChangeTimer2 = setTimer(updateLoadingSpinner, 800, 0) 
    setTimer(cameras, 1500, 1)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(function()
        startLoadingScreen()
    end, 800, 1)
end)
