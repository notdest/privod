-- cp-1251 encoding, because it is windows


metrics = {}
function metrics:new(colrs)
    newObj = {
        colors  = colrs,
        tableId = nil
    }

    self.__index = self
    return setmetatable(newObj, self)
end


function metrics:handleEvent(t_id, msg, row, col)
    if msg == QTABLE_LBUTTONDOWN then
        if    col == 3 then
            exitPrice    = middle + math.floor(rowsCount/2) - row
            buyLimit(futures.class , futures.sec ,workingVolume, exitPrice)
            controlTable:setExitPrice(exitPrice)
        elseif col == 4 then
            if lastStopId == 0 then
                lastStop  = middle + math.floor(rowsCount/2) - row
            end
        elseif col == 5 then
            exitPrice = middle + math.floor(rowsCount/2) - row
            sellLimit(futures.class , futures.sec ,workingVolume, exitPrice)
            controlTable:setExitPrice(exitPrice)
        elseif col == 9 then
            if (robotEnterUp == 0) and (robotEnterDown == 0) then
                local otherStopPrice  = math.floor(middle + math.floor(rowsCount/2) - row - contango + 0.5)/100
                local quotes = getQuoteLevel2 ( share.class , share.sec)

                if      otherStopPrice >= tonumber(quotes.offer[1].price) then
                    robotEnterUp    = otherStopPrice
                elseif  otherStopPrice <= tonumber(quotes.bid[ math.floor(quotes.bid_count) ].price) then
                    robotEnterDown  = otherStopPrice
                end
            else
                dropSharesStop()
            end
            self:printQuotes2()
        end
    elseif msg == QTABLE_MBUTTONDOWN then
        local priceOfClick = middle + math.floor(rowsCount/2) - row
        if    col == 4 then
            if     exitPrice == priceOfClick then
                dropLimit(futures.class,futures.assets)

            elseif (priceOfClick >= lastStop and priceOfClick <= lastRealStop)
                or (priceOfClick <= lastStop and priceOfClick >= lastRealStop) then

                dropFuturesStop()
            end

        elseif col == 3 then                -- ставим метку в покупках
            if mark.buy == 0 then
                mark.buy = priceOfClick
            elseif mark.sell ~= 0 then
                mark.buy  = 0
                mark.sell = 0
            else
                mark.buy = 0
            end
        elseif col == 5 then                -- ставим метку в продажах
            if mark.sell == 0 then
                mark.sell = priceOfClick
            elseif mark.buy ~= 0 then
                mark.buy  = 0
                mark.sell = 0
            else
                mark.sell = 0
            end
        end

    elseif msg == QTABLE_LBUTTONUP then
        if col == 4 then
            if lastStopId == 0 then
                lastRealStop = middle + math.floor(rowsCount/2) - row
                if     lastRealStop > lastStop then
                    buyStop(futures.class , futures.sec, math.abs(curPos), lastRealStop, lastStop)
                elseif lastRealStop < lastStop then
                    sellStop(futures.class , futures.sec, math.abs(curPos), lastRealStop, lastStop)
                else
                    lastRealStop = 0
                    lastStop     = 0
                end
            end
        end
    elseif msg == QTABLE_VKEY then                                                      -- Всякие клавиши


        if     col == 87 then                                                   -- "w", покупка по рынку
            buyFuturesMarket()
        elseif col == 83 then                                                   -- "s", продажа по рынку
            sellFuturesMarket()
        elseif col == 65 then                                                   -- "a", заявка покупка над стаканом
            buyFuturesSpread()
        elseif col == 68 then                                                   -- "d", заявка продажа под стаканом
            sellFuturesSpread()

        elseif col == 38 then                                                   -- стрелка вверх, прокрутить наверх
            setMiddle(middle + 15)
        elseif col == 40 then                                                   -- стрелка вниз,  прокрутить вниз
            setMiddle(middle - 15)


        elseif col == 96 then                                                   -- нуль на панели слева, отцентрировать стакан
            center()
        elseif col == 27 then                                                   -- esc, снять лимитки и стопы
            dropFuturesStop()
            dropSharesStop()

            if openBuys ~= 0 or openSells ~= 0 then
                dropLimit(futures.class,futures.assets)
            end

            self:printQuotes2()
            self:printQuotes()
        elseif col == 46 then                                                   -- del, всё снять, всюду выйти
            dropFuturesStop()
            dropSharesStop()

            if openBuys ~= 0 or openSells ~= 0 then
                dropLimit(futures.class,futures.assets)
            end

            if curPos > 0 then
                sellMarket( futures.class , futures.sec ,math.abs(curPos))
            elseif curPos < 0 then
                buyMarket( futures.class , futures.sec ,math.abs(curPos))
            end

            self:printQuotes2()
            self:printQuotes()


        elseif col == 49 then                                                   -- 1, установить объем
            setWorkingVolume( 1 )
        elseif col == 50 then                                                   -- 2, установить объем
            setWorkingVolume( 2 )
        elseif col == 51 then                                                   -- 3, установить объем
            setWorkingVolume( 5 )
        elseif col == 52 then                                                   -- 4, установить объем
            setWorkingVolume( 10 )
        elseif col == 53 then                                                   -- 5, установить объем
            setWorkingVolume( 15 )
        end

    end
end

function metrics:sharesTrade(trade)
    local row   = self:shareIndex(trade.price)
    if bit.band( trade.flags, 1) ~= 0 then
        self:addTrade(trade,row,7,share.volume)
    else
        self:addTrade(trade,row,6,share.volume)
    end
end

function metrics:futuresTrade(trade)
    local row   = middle + math.floor(rowsCount/2) - trade.price
    if bit.band( trade.flags, 1) ~= 0 then
        self:addTrade(trade,row,2,futures.volume )
    else
        self:addTrade(trade,row,1,futures.volume)
    end
end


function metrics:addTrade( trade,row,col,volumes )          -- мы тут избыточно передаем сделку
    if row >= 1 and row <= rowsCount then
        local oldVal = GetCell(self.tableId,row,col)
        local color, qty

            if oldVal.image == "" then  -- oldVal здесь постоянно nil
                qty = trade.qty
            else
                qty = tonumber(oldVal.image) + trade.qty
            end
            SetCell(self.tableId,row,col, string.format("%d", qty) )

            if bit.band( trade.flags, 1) ~= 0 then
                Highlight(self.tableId, row, col, self.colors.red.heavy , QTABLE_DEFAULT_COLOR , 200)
                local color = self:chooseColor(self.colors.red, volumes, qty)
            else
                Highlight(self.tableId, row, col, self.colors.green.heavy, QTABLE_DEFAULT_COLOR , 200)
                local color = self:chooseColor(self.colors.green, volumes, qty)
            end

            self:color(row,col,color)
    end
end


function metrics:printQuotes()
    quotes           = getQuoteLevel2 ( futures.class , futures.sec)
    endValue         = middle + math.floor(rowsCount/2)
    

    for i = 1, rowsCount do                                 -- выводим линейку у фьюча и очищаем его
        SetCell(self.tableId, i, 4, tostring( endValue - i) )
        SetCell(self.tableId, i, 3, '' )
        SetCell(self.tableId, i, 5, '' )

        self:defaultColor(i, 3)
        self:defaultColor(i, 4)
        self:defaultColor(i, 5)
    end

    for k, v in pairs(quotes.bid) do -- Сбоит иногда, нужно условие
        local index = endValue - v.price
        if index >= 1 and index <= rowsCount then
            local color = self:chooseColor(self.colors.green, futures.volume, v.quantity)

            SetCell(self.tableId,  index, 3, tostring( v.quantity) )
            self:color(index, 3, color)
            self:color(index, 4, color)
        end
    end

    for k, v in pairs(quotes.offer) do
        index   = endValue - v.price
        if index >= 1 and index <= rowsCount then
            local color = self:chooseColor(self.colors.red, futures.volume, v.quantity)

            SetCell(self.tableId,  index, 5, tostring( v.quantity) )

            self:color(index, 5, color)
            self:color(index, 4, color)
        end
    end


    local exitIndex = endValue - exitPrice
    if exitIndex > 0 and exitIndex <= rowsCount then                                        -- подсвечиваем выход
        self:color(exitIndex, 4, RGB(0, 219, 216))
    end

    local markIndex = {buy = endValue - mark.buy , sell = endValue - mark.sell}             -- подсвечиваем пометки
    if markIndex.buy > 0 and markIndex.buy <= rowsCount then
        self:color(markIndex.buy, 3, RGB(177, 195, 59))
    end
    if markIndex.sell > 0 and markIndex.sell <= rowsCount then
        self:color(markIndex.sell, 5, RGB(177, 195, 59))
    end

    local stopIndexLow  = endValue - math.max(lastStop, lastRealStop)                       -- подсвечиваем стоп
    local stopIndexHigh = endValue - math.min(lastStop, lastRealStop)
    if stopIndexLow > 0 and stopIndexLow <= rowsCount and stopIndexHigh > 0 and stopIndexHigh <= rowsCount then
        for i = stopIndexLow, stopIndexHigh do
            self:color(i, 4, RGB(165, 0, 200))
        end
    end

    for k, v in pairs(entrances) do
        index   = endValue - v
        if index > 0 and index <= rowsCount then
            self:color(index, 4, RGB(177, 195, 59))
        end
    end
end


function metrics:printQuotes2()
    quotes          = getQuoteLevel2 ( share.class , share.sec)
    endValue        = math.floor(middle + math.floor(rowsCount/2) - contango + 0.5)

    

    for i = 1, rowsCount do                                 -- выводим линейку у акции и очищаем его
        SetCell(self.tableId, i, 9, string.format("%01.2f", (endValue - i)/100 ) )
        SetCell(self.tableId, i, 8, '' )
        SetCell(self.tableId, i, 10, '' )

        self:defaultColor(i, 8)
        self:defaultColor(i, 9)
        self:defaultColor(i, 10)
    end


    if tonumber(quotes.bid_count) > 0 then
        local summ = 0
        for k, v in pairs(quotes.bid) do
            local index = self:shareIndex( v.price )
            if index >= 1 and index <= rowsCount then
                local color = self:chooseColor(self.colors.green, share.volume, v.quantity)

                SetCell(self.tableId,  index, 8, tostring( v.quantity) )
                self:color(index, 8, color)
                self:color(index, 9, color)
            end

            summ = summ + tonumber(v.quantity)
        end

        local index =  self:shareIndex( quotes.bid[1].price ) + 1
        if index >= 1 and index <= rowsCount then
            SetCell(self.tableId,  index, 8,string.format("*%d", summ))
            self:color(index, 8, self.colors.green.heavy)
        end
    end

    if tonumber(quotes.offer_count) > 0 then
        local summ = 0
        for k, v in pairs(quotes.offer) do
            index   = self:shareIndex( v.price )
            if index >= 1 and index <= rowsCount then
                local color = self:chooseColor(self.colors.red, share.volume, v.quantity)

                SetCell(self.tableId,  index, 10, tostring( v.quantity) )
                self:color(index, 10, color)
                self:color(index,  9, color)
            end

            summ = summ + tonumber(v.quantity)
        end

        local index = self:shareIndex( quotes.offer[math.floor(quotes.offer_count)].price ) - 1
        if index >= 1 and index <= rowsCount then
            SetCell(self.tableId,  index, 10, string.format("%d*", summ) )
            self:color(index, 10, self.colors.red.heavy)
        end
    end


    if robotEnterUp ~= 0 then
        local index     =  self:shareIndex( robotEnterUp )
        local endIndex  = index - 10

        index       = math.min(index, rowsCount)
        endIndex    = math.max(endIndex,1)

        for i=endIndex,index do
            self:color(i, 9, RGB(165, 0, 200))
        end
    end

    if robotEnterDown ~= 0 then
        local index     = self:shareIndex( robotEnterDown )
        local endIndex  = index + 10

        index       = math.max(index, 1)
        endIndex    = math.min(endIndex,rowsCount)

        for i=index, endIndex do
            self:color(i, 9, RGB(165, 0, 200))
        end
    end
end

function metrics:clearTrades()
 	for i = 1, rowsCount do
        SetCell(self.tableId, i, 1, '' )
        SetCell(self.tableId, i, 2, '' )
        SetCell(self.tableId, i, 6, '' )
        SetCell(self.tableId, i, 7, '' )

        self:defaultColor(i, 1)
        self:defaultColor(i, 2)
        self:defaultColor(i, 6)
        self:defaultColor(i, 7)
    end
end 


function metrics:init()
	self.tableId = AllocTable()                                                            -- Создаем таблицу с стаканом
    AddColumn(self.tableId, 1, "пок",      true, QTABLE_INT_TYPE, 7)
    AddColumn(self.tableId, 2, "прод",     true, QTABLE_INT_TYPE, 7)
    AddColumn(self.tableId, 3, "",         true, QTABLE_INT_TYPE, 8)
    AddColumn(self.tableId, 4, "Фьючерс",  true, QTABLE_INT_TYPE, 10)
    AddColumn(self.tableId, 5, "",         true, QTABLE_INT_TYPE, 8)
    AddColumn(self.tableId, 6, "пок",      true, QTABLE_INT_TYPE, 7)
    AddColumn(self.tableId, 7, "прод",     true, QTABLE_INT_TYPE, 7)
    AddColumn(self.tableId, 8, "",         true, QTABLE_INT_TYPE, 8)
    AddColumn(self.tableId, 9, "Акция",    true, QTABLE_INT_TYPE, 10)
    AddColumn(self.tableId, 10, "",        true, QTABLE_INT_TYPE, 8)
    CreateWindow(self.tableId)


    for i = 1, rowsCount do 		-- TODO: выпилить rowsCount
        InsertRow(self.tableId, -1)
    end

    SetWindowCaption(self.tableId, "Стаканы")
    SetTableNotificationCallback(self.tableId,
        function (t_id, msg, row, col)
            self:handleEvent(t_id, msg, row, col)
        end
    )

    SetWindowPos(self.tableId,
        1349,    -- left
        0,    	-- top
        555,    -- width
        893)    -- height
end

function metrics:checkClosed()
    if IsWindowClosed(self.tableId) then
        OnStop()
    end
end

function metrics:close()
    if self.tableId ~= nil then
        DestroyTable(self.tableId)
    end
end

-------------------------------------дальше типо приватные методы

function metrics:shareIndex( price )
    local endValue = middle + math.floor(rowsCount/2) - contango
    return math.floor( endValue - price*100 + 0.5)
end

function metrics:defaultColor(row,col)
    SetColor(self.tableId, row, col, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
end

function metrics:color(row,col,color)
    SetColor(self.tableId, row, col, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
end

function metrics:chooseColor( color,volume,quantity )
    local ret = color.heavy

    if tonumber(quantity) < volume.medium then
        ret = color.light
    elseif tonumber(quantity) < volume.high then
        ret = color.medium
    end

    return ret
end