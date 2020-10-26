

control = {}
function control:new(colrs)
    newObj = {
        colors  = colrs,
        tableId = nil
    }

    self.__index = self
    return setmetatable(newObj, self)
end


-- Я пока не могу отказаться от использования глобальных функций, получается что надо сделать шаг двумя ногами сразу
-- но позже надо будет их отсюда убрать

function control:handleEvent(t_id, msg, row, col)
    if     msg == QTABLE_LBUTTONDOWN then

        if     col == 1 then                                                                -- Контанго
            if     row == 1 then
                addContango(1)
            elseif row == 3 then
                addContango(-1)
            elseif row == 4 then
                calculateProfit()
            end


        elseif col == 2 then                                                                -- Рабочий объем
            if     row == 1 then
                addWorkingVolume( 1)
            elseif row == 3 then
                addWorkingVolume(-1)
            end


        elseif col == 3 then                                                                -- Рыночные
            if     row == 1 then
                buyFuturesMarket()
            elseif row == 3 then
                sellFuturesMarket()
            end


        elseif col == 4 then
            if     row == 1 then                                                            -- Лимитки
                sellFuturesSpread()
            elseif row == 2 then
                dropFuturesLimit()
            elseif row == 3 then
                buyFuturesSpread()
            end


        elseif col == 5 then                                                                -- Стопы
            if     row == 2 then
                dropFuturesStop()
            end
        end

    elseif msg == QTABLE_MBUTTONDOWN then
        if     col == 1 then
            if     row == 1 then
                addContango( 10)
            elseif row == 3 then
                addContango(-10)
            end
        end
    end

end

-- Потом надо уменьшить количество входных параметров
function control:addTradeToControl( trade,row,col,volumes )
    local oldVal = GetCell(self.tableId,row,col)
    local color, qty

    qty = ((oldVal == nil) and 0 or tonumber(oldVal.image)) + trade.qty

    SetCell(self.tableId,row,col, string.format("%d", qty) )

    if bit.band( trade.flags, 1) ~= 0 then
        color   = self.colors.red.heavy

        if      qty < volumes.medium    then
            color = self.colors.red.light
        elseif  qty < volumes.high      then
            color = self.colors.red.medium
        end
    else
        color   = self.colors.green.heavy

        if      qty < volumes.medium    then
            color = self.colors.green.light
        elseif  qty < volumes.high      then
            color = self.colors.green.medium
        end
    end

    SetColor(self.tableId, row, col, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
end


function control:shiftOrders( volumes )
    local color, qty

    for i=1,4 do
        qty = tonumber(GetCell(self.tableId,5,i+1).image)

        color   = self.colors.red.heavy         -- Это тоже можно растащить. В этой функции цвета раздельно вычисляются, для верхних и нижних
        if      qty < volumes.medium    then    -- а в соседней как бы непонятно изначально, куда запишем
            color = self.colors.red.light
        elseif  qty < volumes.high      then
            color = self.colors.red.medium
        end
        SetCell(self.tableId,5,i, string.format("%d", qty) )
        SetColor(self.tableId, 5, i, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)


        qty = tonumber(GetCell(self.tableId,6,i+1).image)
        color   = self.colors.green.heavy
        if      qty < volumes.medium    then
            color = self.colors.green.light
        elseif  qty < volumes.high      then
            color = self.colors.green.medium
        end
        SetCell(self.tableId,6,i, string.format("%d", qty) )
        SetColor(self.tableId, 6, i, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    end


    SetCell(self.tableId,5,5, '0' )
    SetCell(self.tableId,6,5, '0' )

    SetColor(self.tableId, 5, 5, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetColor(self.tableId, 6, 5, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
end

function control:setPosition(pos,buys,sells)
    if      pos == 0 then
        SetColor(self.tableId, 2, 3, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    elseif  pos > 0 then
        SetColor(self.tableId, 2, 3, self.colors.green.heavy, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    elseif  pos < 0 then
        SetColor(self.tableId, 2, 3, self.colors.red.heavy, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    end

    SetCell(self.tableId, 2, 3, tostring(pos) )
    SetCell(self.tableId, 2, 4, "+"..buys..", -"..sells.." (снять)" )
end

function control:setExitPrice(val)
    SetCell(self.tableId, 4, 4, "Вых: "..val )
end


function control:setWorkingVolume(val)
    SetCell(self.tableId, 2, 2, tostring(val) )
end


function control:setContango(val)
    SetCell(self.tableId, 2, 1, tostring(val) )
end


function control:setProfit(val)
    SetCell(self.tableId, 4, 1, string.format("%01.2f", val ) )
end


function control:setStop(val)
    SetCell(self.tableId, 2, 5,  val .." (снять)" )
end


function control:init(vol)
    self.tableId = AllocTable()                                                            -- Создаем таблицу с элементами управления
    AddColumn(self.tableId, 1, "Контанго",         true, QTABLE_CACHED_STRING_TYPE, 12)
    AddColumn(self.tableId, 2, "Рабочий объем",    true, QTABLE_CACHED_STRING_TYPE, 17)
    AddColumn(self.tableId, 3, "Войти по рынку",   true, QTABLE_CACHED_STRING_TYPE, 17)
    AddColumn(self.tableId, 4, "Выйти",            true, QTABLE_CACHED_STRING_TYPE, 12)
    AddColumn(self.tableId, 5, "Стопы",            true, QTABLE_CACHED_STRING_TYPE, 12)
    CreateWindow(self.tableId)


    data = {
        {"+ (++ cкм)", "Вверх",                 "Вверх",        "Сверху",           ""       },
        {"0",          tostring(vol),           "0",            "+0, -0 (снять)",   ""       },
        {"- (-- cкм)", "Вниз",                  "Вниз",         "Снизу",            ""       },
        {"",           "",                      " ",            "Вых: 0",           "Ручной" },
        {"0",          "0",                     "0",            "0",                "0"      },
        {"0",          "0",                     "0",            "0",                "0"      }
    }

    for k, v in pairs(data) do
        row = InsertRow(self.tableId, -1)
        SetCell(self.tableId, row, 1, v[1])
        SetCell(self.tableId, row, 2, v[2])
        SetCell(self.tableId, row, 3, v[3])
        SetCell(self.tableId, row, 4, v[4])
        SetCell(self.tableId, row, 5, v[5])
    end

    SetWindowCaption(self.tableId, "Управление")

    SetTableNotificationCallback(self.tableId, 
        function (t_id, msg, row, col)
            self:handleEvent(t_id, msg, row, col)
        end
    )

    SetWindowPos(self.tableId,
        280,    -- left
        550,    -- top
        470,    -- width
        140)    -- height
end



function control:close()
    if self.tableId ~= nil then
        DestroyTable(self.tableId)
    end
end