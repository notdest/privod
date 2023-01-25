-- cp-1251 encoding, because it is windows

function buyMarket(class, sec, count)
    local result    = ""

    local transaction = {
        TRANS_ID                = "104",
        CLASSCODE               = class,
        ACTION                  = "Ввод заявки",
        ["Торговый счет"]       = tradingAccount,
        ["К/П"]                 = "Покупка",
        ["Тип"]                 = "Рыночная",
        ["Класс"]               = class,
        ["Инструмент"]          = sec,
        ["Цена"]                = '0',
        ["Количество"]          = tostring(count),
        ["Условие исполнения"]  = "Поставить в очередь",
        ["Комментарий"]         = clientCode,
        ["Переносить заявку"]   = "Нет",
        ["Дата экспирации"]     = os.date("%Y%m%d")
    }


    result  = sendTransaction(transaction)

    if result ~= "" then
        message("Сбой транзакции: "..result)
    end
end


function sellMarket(class, sec, count)
    local result    = ""

    local transaction = {
        TRANS_ID                = "105",
        CLASSCODE               = class,
        ACTION                  = "Ввод заявки",
        ["Торговый счет"]       = tradingAccount,
        ["К/П"]                 = "Продажа",
        ["Тип"]                 = "Рыночная",
        ["Класс"]               = class,
        ["Инструмент"]          = sec,
        ["Цена"]                = '0',
        ["Количество"]          = tostring(count),
        ["Условие исполнения"]  = "Поставить в очередь",
        ["Комментарий"]         = clientCode,
        ["Переносить заявку"]   = "Нет",
        ["Дата экспирации"]     = os.date("%Y%m%d")
    }

    result  = sendTransaction(transaction)

    if result ~= "" then
        message("Сбой транзакции: "..result)
    end
end



function buyLimit(class, sec, count, price)
    local transaction = {
        TRANS_ID                = "104",
        CLASSCODE               = class,
        ACTION                  = "Ввод заявки",
        ["Торговый счет"]       = tradingAccount,
        ["К/П"]                 = "Покупка",
        ["Тип"]                 = "Лимитированная",
        ["Класс"]               = class,
        ["Инструмент"]          = sec,
        ["Цена"]                = tostring(price),
        ["Количество"]          = tostring(count),
        ["Условие исполнения"]  = "Поставить в очередь",
        ["Комментарий"]         = clientCode,
        ["Переносить заявку"]   = "Нет",
        ["Дата экспирации"]     = os.date("%Y%m%d")
    }

    return sendTransaction(transaction)
end


function sellLimit(class, sec, count, price)
    local transaction = {
        TRANS_ID                = "105",
        CLASSCODE               = class,
        ACTION                  = "Ввод заявки",
        ["Торговый счет"]       = tradingAccount,
        ["К/П"]                 = "Продажа",
        ["Тип"]                 = "Лимитированная",
        ["Класс"]               = class,
        ["Инструмент"]          = sec,
        ["Цена"]                = tostring(price),
        ["Количество"]          = tostring(count),
        ["Условие исполнения"]  = "Поставить в очередь",
        ["Комментарий"]         = clientCode,
        ["Переносить заявку"]   = "Нет",
        ["Дата экспирации"]     = os.date("%Y%m%d")
    }

    return sendTransaction(transaction)
end


function dropLimit(class,assets)
    local transaction = {
        TRANS_ID                = "104",
        CLASSCODE               = class,
        ACTION                  = "Удалить все заявки по условию",
        ["Торговый счет"]       = tradingAccount,
        ["Направленность"]      = "Все",
        ["Тип заявки"]          = "Все",
        ["Базовый актив"]       = assets
    }

    return sendTransaction(transaction)
end


function buyStop(class, sec, count, price, stopPrice)
    transaction = {
        TRANS_ID                = "108",
        CLASSCODE               = class,
        ACTION                  = "Стоп-заявка",
        ["Тип стоп-заявки"]     = "Стоп-лимит",
        ["Действует по"]        = "-1",
        ["Торговый счет"]       = tradingAccount,
        ["К/П"]                 = "Купля",
        ["Условие"]             = ">=",
        ["Стоп-цена"]           = tostring(stopPrice),
        ["Флаги"]               = "2",
        ["Режим"]               = class,
        ["Инструмент"]          = sec,
        ["Бумага заявки"]       = sec,
        ["Класс заявки"]        = class,
        ["Цена"]                = tostring(price),
        ["Количество"]          = tostring(count),
        ["Примечание"]          = clientCode,
        ["Цена лим. заявки"]    = "0",
        ["Отступ"]              = "0,000000",
        ["Защ. спред"]          = "0,000000",
        ["Номер баз. заявки"]   = "0",
        ["Активна с"]           = "0",
        ["Активна по"]          = "235959",
        ["Стоп-цена2"]          = "0",
    }

    return sendTransaction(transaction)
end


function sellStop(class, sec, count, price, stopPrice)
    transaction = {
        TRANS_ID                = "108",
        CLASSCODE               = class,
        ACTION                  = "Стоп-заявка",
        ["Тип стоп-заявки"]     = "Стоп-лимит",
        ["Действует по"]        = "-1",
        ["Торговый счет"]       = tradingAccount,
        ["К/П"]                 = "Продажа",
        ["Условие"]             = "<=",
        ["Стоп-цена"]           = tostring(stopPrice),
        ["Флаги"]               = "2",
        ["Режим"]               = class,
        ["Инструмент"]          = sec,
        ["Бумага заявки"]       = sec,
        ["Класс заявки"]        = class,
        ["Цена"]                = tostring(price),
        ["Количество"]          = tostring(count),
        ["Примечание"]          = clientCode,
        ["Цена лим. заявки"]    = "0",
        ["Отступ"]              = "0,000000",
        ["Защ. спред"]          = "0,000000",
        ["Номер баз. заявки"]   = "0",
        ["Активна с"]           = "0",
        ["Активна по"]          = "235959",
        ["Стоп-цена2"]          = "0",
    }

    return sendTransaction(transaction)
end

function dropStop(class, id )
    transaction = {
        TRANS_ID                = "101",
        CLASSCODE               = class,
        ACTION                  = "Снять стоп-заявку",
        ["Номер Стоп-Заявки"]   = tostring(id),
    }

    return sendTransaction(transaction)
end