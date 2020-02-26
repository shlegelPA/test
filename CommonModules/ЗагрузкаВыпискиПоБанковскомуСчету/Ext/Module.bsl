﻿
//При загрузке банковской выписки если балансовый счет банка равен 47423 "Требования по прочим операциям" (Выплаты по эквайрингу),
//то будем искать договор по доп реквизиту "НомерТерминалаЭкайринга"  
&После("УстановитьНайденныйДоговор")
Процедура ОМ_ЗВБС_УстановитьНайденныйДоговор(ХозяйственнаяОперация, ОписаниеДоговора, Параметры)
	Если Параметры.Операция.БалансовыйСчет = "47423" Тогда
		//отбор договоров по доп реквизиту
		ДопРеквизитДоговора = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "НомерТерминалаЭкайринга");
		//Список уже отобранных обработкой договоров по виду и по контрагенту
		Договоры = Параметры.ПротоколыВыбораСсылок.ДоговорКонтрагента.ВыгрузитьКолонку("Ссылка");
		//уберем точки, назначение платежа ИД терминала заканчивается на точку
		//разделим строку по пробелам
		МассивВозможныхЗначений = СтрРазделить(СтрЗаменить(Параметры.Операция.НазначениеПлатежа,".",""), " ", Ложь);
		
		//Выберем договора по свойству и значению из предоставленного списка
		Запрос = Новый Запрос("ВЫБРАТЬ
								|	ДоговорыКонтрагентовДополнительныеРеквизиты.Свойство КАК Свойство,
								|	ДоговорыКонтрагентовДополнительныеРеквизиты.Значение КАК Значение,
								|	ДоговорыКонтрагентовДополнительныеРеквизиты.Ссылка КАК Ссылка
								|ПОМЕСТИТЬ ВтДоговоры
								|ИЗ
								|	Справочник.ДоговорыКонтрагентов.ДополнительныеРеквизиты КАК ДоговорыКонтрагентовДополнительныеРеквизиты
								|ГДЕ
								|	ДоговорыКонтрагентовДополнительныеРеквизиты.Ссылка В (&СписокДоговоров)
								|;
								|
								|////////////////////////////////////////////////////////////////////////////////
								|ВЫБРАТЬ
								|	ВтДоговоры.Ссылка КАК Ссылка
								|ИЗ
								|	ВтДоговоры КАК ВтДоговоры
								|ГДЕ
								|	ВтДоговоры.Свойство = &Свойство
								|	И ВтДоговоры.Значение В (&Значение)");
	    
		Запрос.УстановитьПараметр("СписокДоговоров", Договоры);
		Запрос.УстановитьПараметр("Значение", МассивВозможныхЗначений);
		Запрос.УстановитьПараметр("Свойство", ДопРеквизитДоговора);
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		//Если нашли договор
		Если Выборка.Следующий() Тогда
			ХозяйственнаяОперация.ДоговорКонтрагента = Выборка.Ссылка;
		Иначе
			//оставляем пустой, чтобы бухгалтер мог сам выбрать или создать новый договор по эквайрингу
			ХозяйственнаяОперация.ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
		КонецЕсли;
	
	КонецЕсли;
	
КонецПроцедуры

