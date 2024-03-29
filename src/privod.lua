-- cp-1251 encoding, because it is windows

rowsCount   = 80    -- ��������� ������� � ������������

updateInterval  = 300
eraseInterval   = 60000

colors  = {
    green   = {light = RGB(29, 36, 27), medium = RGB(32, 54, 26), heavy = RGB(35, 74, 25) },
    red     = {light = RGB(55, 31, 31), medium = RGB(76, 35, 35), heavy = RGB(116, 41, 41) }
}






dofile (getScriptPath() .. "\\src\\tradingFunctions.lua")
dofile (getScriptPath() .. "\\src\\controlTable.lua")
dofile (getScriptPath() .. "\\src\\metricsTable.lua")


lastStopId      = 0

middle          = 0
contango        = 0
curPos          = 0
openBuys        = 0
openSells       = 0
exitPrice       = 0
workingVolume   = 1
morningPos      = 0     -- ������ �� ������ ������, ��� ���������� �� ������ ������� ������

mark    = {
    buy     = 0,
    sell    = 0
}

entrances   = { }

isRun   = true

dofile (getScriptPath() .. "\\src\\interfaceFunctions.lua")

    function OnInit()
        morningPos      = getMorningPos()
        controlTable    = control:new(colors)
        metricsTable    = metrics:new(colors)
        entrances       = getEntrances()
    end

    function OnStop()
        isRun = false
        controlTable:close()
        metricsTable:close()
    end

    function OnStopOrder(order)
        if bit.band( order.flags, 1) == 0 and lastStopId == order.order_num then
            displayNoStop()
        end
    end

    partialDeals    = {} -- ������, ��� ��������� ������ �����
    function OnOrder( order)

        if order.trans_id > 0 and order.balance < order.qty then                    -- ��� ������� �������� ���������
            local oldBalance = order.qty
            if partialDeals[order.ordernum] ~= nil then
                oldBalance  = partialDeals[order.ordernum]
            end

            if oldBalance - order.balance > 0 then          -- ���� �� ��������� ������
                entrances   = getEntrances()

                if order.balance > 0 and bit.band( order.flags, 1) ~= 0 then
                    partialDeals[order.ordernum] = order.balance
                end
            end

            if  (partialDeals[order.ordernum] ~= nil)   -- ������ �����������, �� ������ �� �������
                and (order.balance == 0 or bit.band( order.flags, 1) == 0) then
                    partialDeals[order.ordernum] = nil
            end
        end


    end


    function OnQuote(class, sec )
        if     class == futures.class and sec == futures.sec then
            metricsTable:printQuotes()
        elseif class == share.class   and sec == share.sec   then


            if robotEnterUp > 0 or robotEnterDown > 0 then
                quotes  = getQuoteLevel2 ( share.class , share.sec)
                sharePriceReached(tonumber(quotes.offer[1].price))
                sharePriceReached(tonumber(quotes.bid[ math.floor(quotes.bid_count) ].price))
            end

            metricsTable:printQuotes2()
        end
    end

    function OnTransReply(reply)
        if reply.status == 3 then
            if reply.trans_id == 108 then       -- ����� � ����� id, ���� �������� �� ���������
                lastStopId   = reply.order_num
                controlTable:setStop(reply.quantity)
            end
        end
    end


    function OnFuturesClientHolding( futPos)
        if futPos.sec_code == futures.sec then

            local lastPos   = curPos

            curPos      = futPos.totalnet
            openBuys    = futPos.openbuys
            openSells   = futPos.opensells

            if curPos == 0 then
                dropFuturesStop()

                if (openBuys ~= 0 or openSells ~= 0) and lastPos ~= curPos then
                    dropLimit(futures.class,futures.assets)
                end

                calculateProfit()
            end

            controlTable:setPosition(curPos, openBuys, openSells)

            if openBuys == 0 and openSells == 0 then
                exitPrice = 0
                controlTable:setExitPrice(exitPrice)
            end
        end
    end



    function OnAllTrade( trade )                                                            -- ��������� ������������ ������
        if     trade.class_code == futures.class and trade.sec_code == futures.sec then
            metricsTable:futuresTrade(trade)
        elseif trade.class_code == share.class   and trade.sec_code == share.sec then
            sharePriceReached(trade.price)
            metricsTable:sharesTrade(trade)
            controlTable:addTrade(trade)
        end
    end



    robotEnterUp    = 0
    robotEnterDown  = 0

    function sharePriceReached(price)
        if      robotEnterUp   > 0 and price >= robotEnterUp then
            buyFuturesMarket()
            dropSharesStop()
        elseif  robotEnterDown > 0 and price <= robotEnterDown then
            sellFuturesMarket()
            dropSharesStop()
        end
    end


    function main()
        controlTable:init(workingVolume)
        metricsTable:init()


        local quotesF = getQuoteLevel2 ( futures.class , futures.sec)
        local quotesS = getQuoteLevel2 ( share.class   , share.sec)
        if tonumber(quotesF.offer_count) > 0 and tonumber(quotesS.offer_count) > 0 then
            addContango( quotesF.offer[1].price - quotesS.offer[1].price*100)
        end

        center()                             -- ��������� �������
        
        local lastErase = 0
        while isRun do
            if lastErase >= eraseInterval then
                lastErase   = 0
                clearTrades()
            end
            lastErase = lastErase + updateInterval

            metricsTable:checkClosed()

            sleep(updateInterval)
        end
    end