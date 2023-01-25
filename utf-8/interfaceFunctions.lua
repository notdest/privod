-- cp-1251 encoding, because it is windows

    function clearTrades()
        controlTable:shiftOrders(share.volume)
        metricsTable:clearTrades()
    end



    -- Отцентрировать отображение стаканов по фьючерсу
    function center()
        local quotes        = getQuoteLevel2 ( futures.class , futures.sec)
        local bidCount      = math.floor(quotes.bid_count)
        local offerCount    = math.floor(quotes.offer_count)

        if offerCount >= 1 and bidCount >= 1 then
            setMiddle( math.ceil(  (quotes.offer[1].price + quotes.bid[ bidCount ].price )/2  ) )
        elseif offerCount >= 1 then
            setMiddle( math.ceil( quotes.offer[1].price ) )
        elseif bidCount >= 1 then
            setMiddle( math.ceil( quotes.bid[ bidCount ].price ) )
        end
    end

    function setMiddle( newVal)
        middle = newVal
        clearTrades()
        metricsTable:printQuotes()
        metricsTable:printQuotes2()
    end

    function addWorkingVolume(step)
        workingVolume = workingVolume + step
        controlTable:setWorkingVolume(workingVolume)
    end

    function setWorkingVolume( val )
        workingVolume = val
        controlTable:setWorkingVolume(workingVolume)
    end

    function addContango(step)
        contango = contango + step
        controlTable:setContango(contango)
        metricsTable:printQuotes2()
        clearTrades()
    end

    function buyFuturesMarket()
        buyMarket( futures.class , futures.sec ,workingVolume)
    end

    function sellFuturesMarket()
        sellMarket( futures.class , futures.sec ,workingVolume)
    end

    function sellFuturesSpread()
        local quotes = getQuoteLevel2 ( futures.class , futures.sec)
        exitPrice    = quotes.offer[1].price - 1
        sellLimit(futures.class , futures.sec ,workingVolume, string.format("%u", exitPrice ) )
        controlTable:setExitPrice(exitPrice)
    end

    function buyFuturesSpread()
        local quotes = getQuoteLevel2 ( futures.class , futures.sec)
        exitPrice    = quotes.bid[ math.floor(quotes.bid_count) ].price + 1
        buyLimit(futures.class , futures.sec ,workingVolume, string.format("%u", exitPrice ))
        controlTable:setExitPrice(exitPrice)
    end

    function setFuturesStop( price )
        if lastStopId ~= 0 then
            dropFuturesStop()
        end

        if      curPos > 0 then
            sellStop(futures.class , futures.sec, math.abs(curPos), price - 50, price)
            metricsTable:setStop( price, -1 )
        elseif  curPos < 0 then
            buyStop( futures.class , futures.sec, math.abs(curPos), price + 50, price)
            metricsTable:setStop( price, 1 )
        end

    end

    function dropFuturesLimit()
        dropLimit(futures.class,futures.assets)
    end

    function dropFuturesStop()
        if lastStopId ~= 0 then
            dropStop(futures.class, lastStopId )
            displayNoStop()
        end
    end

    function dropSharesStop()
        robotEnterUp    = 0
        robotEnterDown  = 0
    end

    function displayNoStop()
        lastStopId   = 0
        metricsTable:setStop( 0, 0 )
        controlTable:setStop(0)
    end

    function calculateProfit()
        controlTable:setProfit(getProfit(2.48,0.5))
    end

    function getProfit( buyCommission,sellComission )
        local qty               = morningPos
        local summ              = 0
        local profit            = 0
        local needCorrection    = (0 ~= morningPos)

        for i = 0,getNumberOf('trades') - 1 do
            item    = getItem('trades',i)

            if item.class_code == futures.class and item.sec_code == futures.sec
                and item.datetime.day == os.date("*t").day  then

                if bit.band( item.flags, 4) ~= 0 then   -- это продажа?
                    qty     = qty - item.qty
                    summ    = summ + item.qty*item.price - item.qty*sellComission
                else    
                    qty     = qty + item.qty
                    summ    = summ - item.qty*item.price - item.qty*buyCommission
                end

                if qty == 0 then
                    if needCorrection then
                        summ            = 0
                        needCorrection  = false
                    else
                        profit = summ
                    end 
                end
            end
        end

        return profit
    end

    -- позицию на начало сесси вычисляем как разность количество бумаг по сделкам и текущей позиции
    function getMorningPos()
        local qty       = 0

        for i = 0,getNumberOf('trades') - 1 do
            item    = getItem('trades',i)

            if item.class_code == futures.class and item.sec_code == futures.sec then
                if bit.band( item.flags, 4) ~= 0 then   -- это продажа?
                    qty     = qty - item.qty
                else
                    qty     = qty + item.qty
                end
            end
        end

        local futPos = getFuturesHolding( firmId, tradingAccount , futures.sec , 0)

        if futPos == nil then
            message("check firmId")
            return 0
        else
            return futPos.totalnet-qty
        end
    end

    function getEntrances()
        local qty       = morningPos
        local lastZero  = -1

        for i = 0,getNumberOf('trades') - 1 do                      -- вычисляем индекс последнего нуля
            item    = getItem('trades',i)

            if item.class_code == futures.class and item.sec_code == futures.sec then
                if bit.band( item.flags, 4) ~= 0 then   -- это продажа?
                    qty     = qty - item.qty
                else    
                    qty     = qty + item.qty
                end

                if qty == 0 then
                    lastZero    = i
                end
            end
        end

        if( lastZero >= (getNumberOf('trades') - 1)) then           -- если мы в нуле, то выходим
            return {}
        end

        item    = getItem('trades',lastZero +1)                     -- определяем, мы в шорте или в лонге
        local globalDirection = (bit.band( item.flags, 4) ~= 0)
        local localDirection  = false

        local movements = {}                                        -- делаем "массив движений" - одна ячейка это один контракт по указанной цене
        for i=lastZero+1 ,getNumberOf('trades') - 1 do
            item    = getItem('trades',i)
            localDirection  = (bit.band( item.flags, 4) ~= 0)

            if localDirection == globalDirection then
                for i=1,item.qty do
                    table.insert(movements, item.price)
                end
            else
                for i=1,item.qty do
                    movements[#movements] = nil
                end
            end 
        end

        local hash  = {}
        local res   = {}

        for _,v in ipairs(movements) do                             -- переводим "массив движений" в массив цен входа
           if (not hash[v]) then
               res[#res+1] = v
               hash[v] = true
           end
        end

        return res
    end


--  отладочные функции

    function printArray( arr )
        message("      ")
        for k, v in pairs(arr) do
            if type(v) == "table" then
                message(k..": таблица")
            else
                message(k..": "..v)
            end
        end
        message("      ")
    end