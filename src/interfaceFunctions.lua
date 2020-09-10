
    function clearTrades()
        shiftOrders(share.volume)
        for i = 1, rowsCount do
            SetCell(metricsId, i, 1, '' )
            SetCell(metricsId, i, 2, '' )
            SetCell(metricsId, i, 6, '' )
            SetCell(metricsId, i, 7, '' )

            SetColor(metricsId, i, 1, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
            SetColor(metricsId, i, 2, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
            SetColor(metricsId, i, 6, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
            SetColor(metricsId, i, 7, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        end
    end

    function shiftOrders( volumes )
        local color, qty

        for i=1,4 do
            qty = tonumber(GetCell(controlId,5,i+1).image)

            color   = colors.red.heavy
            if      qty < volumes.medium    then
                color = colors.red.light
            elseif  qty < volumes.high      then
                color = colors.red.medium
            end
            SetCell(controlId,5,i, string.format("%d", qty) )
            SetColor(controlId, 5, i, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)


            qty = tonumber(GetCell(controlId,6,i+1).image)
            color   = colors.green.heavy
            if      qty < volumes.medium    then
                color = colors.green.light
            elseif  qty < volumes.high      then
                color = colors.green.medium
            end
            SetCell(controlId,6,i, string.format("%d", qty) )
            SetColor(controlId, 6, i, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        end


        SetCell(controlId,5,5, '0' )
        SetCell(controlId,6,5, '0' )

        SetColor(controlId, 5, 5, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(controlId, 6, 5, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    end

    function setMiddle()
        quotes = getQuoteLevel2 ( futures.class , futures.sec)
        middle = math.ceil(  (quotes.offer[1].price + quotes.bid[ math.floor(quotes.bid_count) ].price )/2  )
        clearTrades()
        printQuotes()
        printQuotes2()
    end

    function addContango(step)
        contango = contango + step
        SetCell(controlId, 2, 1, tostring(contango) )
        printQuotes2()
        clearTrades()
    end

    function displayNoStop()
        stopQuantity = 0
        lastStopId   = 0
        lastStop     = 0
        lastRealStop = 0
        SetCell(controlId, 2, 5, tostring(stopQuantity.." (снять)") )
    end

    function getProfit( buyCommission,sellComission )
        local qty               = morningPos
        local summ              = 0
        local profit            = 0
        local needCorrection    = (0 ~= morningPos)

        for i = 0,getNumberOf('trades') - 1 do
            item    = getItem('trades',i)

            if item.class_code == futures.class and item.sec_code == futures.sec then
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

        local futPos = getFuturesHolding( "SPBFUT01", tradingAccount , futures.sec , 0)         -- aaaaaaaaaaaa, Внимание!!! SPBFUT01 надо выпилить


        return futPos.totalnet-qty
    end




    function addTrade( trade,row,col,volumes )
        if row >= 1 and row <= rowsCount then
            local oldVal = GetCell(metricsId,row,col)
            local color, qty

                if oldVal.image == "" then
                    qty = trade.qty
                else
                    qty = tonumber(oldVal.image) + trade.qty
                end
                SetCell(metricsId,row,col, string.format("%d", qty) )

                if bit.band( trade.flags, 1) ~= 0 then
                    Highlight(metricsId, row, col, colors.red.heavy , QTABLE_DEFAULT_COLOR , 200)

                    color   = colors.red.heavy

                    if      qty < volumes.medium    then
                        color = colors.red.light
                    elseif  qty < volumes.high      then
                        color = colors.red.medium
                    end
                else
                    Highlight(metricsId, row, col, colors.green.heavy, QTABLE_DEFAULT_COLOR , 200)

                    color   = colors.green.heavy

                    if      qty < volumes.medium    then
                        color = colors.green.light
                    elseif  qty < volumes.high      then
                        color = colors.green.medium
                    end
                end

                SetColor(metricsId, row, col, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        end
    end


    function addTradeToControl( trade,row,col,volumes )
        local oldVal = GetCell(controlId,row,col)
        local color, qty

            qty = tonumber(oldVal.image) + trade.qty

            SetCell(controlId,row,col, string.format("%d", qty) )

            if bit.band( trade.flags, 1) ~= 0 then
                color   = colors.red.heavy

                if      qty < volumes.medium    then
                    color = colors.red.light
                elseif  qty < volumes.high      then
                    color = colors.red.medium
                end
            else
                color   = colors.green.heavy

                if      qty < volumes.medium    then
                    color = colors.green.light
                elseif  qty < volumes.high      then
                    color = colors.green.medium
                end
            end

            SetColor(controlId, row, col, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
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