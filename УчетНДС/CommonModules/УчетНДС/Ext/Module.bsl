﻿
&ИзменениеИКонтроль("ПечатьУниверсальныхПередаточныхДокументов981")
Функция ОМ_УчетНДС_ПечатьУниверсальныхПередаточныхДокументов981(МассивОбъектов, ОбъектыПечати, ТекстЗапросаДокументам, ТолькоПередаточныйДокумент, ТабДокумент, ПараметрыПечати)

	Если ТабДокумент = Неопределено Тогда
		ТабДокумент = Новый ТабличныйДокумент;
	Иначе
		ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
	КонецЕсли;

	ТабДокумент.АвтоМасштаб        = Истина;
	#Удаление
	ТабДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	#КонецУдаления
	#Вставка
	
	#Область ИзменениеОриентацииСтраницы_ШлегельА

	Если ПараметрыПечати.Свойство("Ориентация") Тогда
		
		ТабДокумент.ОриентацияСтраницы = ПараметрыПечати.Ориентация;
		
	Иначе	
		
		ТабДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
		
	КонецЕсли;
	
	#КонецОбласти
	#КонецВставки
	ТабДокумент.ЭкземпляровНаСтранице = 1;

	ТабДокумент.КлючПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_УниверсальныйПередаточныйДокумент_981";

	УстановкаМинимальныхПолейДляПечати(ТабДокумент);

	Макет = УправлениеПечатью.МакетПечатнойФормы("Обработка.ПечатьУПД.ПФ_MXL_УниверсальныйПередаточныйДокумент981");

	Возврат ТабличныйДокументУПД(
	Макет, МассивОбъектов, ОбъектыПечати, ТабДокумент, ТекстЗапросаДокументам, ТолькоПередаточныйДокумент, ПараметрыПечати);

КонецФункции

&ИзменениеИКонтроль("ТабличныйДокументУПД")
Функция ОМ_УчетНДС_ТабличныйДокументУПД(Макет, МассивОбъектов, ОбъектыПечати, ТабДокумент, ТекстЗапросаДокументам, ТолькоПередаточныйДокумент, ПараметрыПечати)

	// Исключим из массива документы на чтение которых у пользователя нет прав
	УправлениеДоступомБП.УдалитьНедоступныеЭлементыИзМассива(МассивОбъектов);

	УстановитьПривилегированныйРежим(Истина);

	Если МассивОбъектов.Количество() = 0 Тогда
		ДанныеУниверсальныхПередаточныхДокументов = НовыйТаблицаСчетовФактур();
	ИначеЕсли ТолькоПередаточныйДокумент Тогда
		ДанныеУниверсальныхПередаточныхДокументов = ПолучитьДанныеДляПечатиУниверсальногоПередаточногоДокумента(
		МассивОбъектов, ТекстЗапросаДокументам);
	Иначе
		ДанныеУниверсальныхПередаточныхДокументов = ПолучитьДанныеДляПечатиСчетаФактуры1137(
		МассивОбъектов, ТекстЗапросаДокументам, Истина);
	КонецЕсли;

	ПервыйДокумент = Истина;

	СтрокиПечати = Новый СписокЗначений;

	Для Каждого ВыборкаУПД ИЗ ДанныеУниверсальныхПередаточныхДокументов Цикл

		ОбъектыПечати.Добавить(ВыборкаУПД.Ссылка);

		Если ВыборкаУПД.Дата < '20130101' Тогда
			Продолжить;
		КонецЕсли;

		ТаблицаДокумента = ВыборкаУПД.ТаблицаДокумента;
		Если ТаблицаДокумента = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Если НЕ ПервыйДокумент Тогда
			ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			#Вставка
			#Область Шлегель_АН_Для_ДвухстороннейПечати
			//Для двухсторонней печати. Чтобы второй документ не печатался на обратной стороне первого
			Если (ТабДокумент.КоличествоСтраниц() % 2) <> 0 Тогда
				//Вставим пустую ячейку для вывода пустой страницы
				ТабДокумент.Вывести(Макет.ПолучитьОбласть("Строка").ПолучитьОбласть("R1C1"));
				ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			КонецЕсли;
			#КонецОбласти
			#КонецВставки
		КонецЕсли;
		ПервыйДокумент = Ложь;

		// Запомним номер строки, с которой начали выводить текущий документ.
		НомерСтрокиНачало = ТабДокумент.ВысотаТаблицы + 1;

		ВывестиСчетФактуруВТабличныйДокумент(ТабДокумент, Макет, ВыборкаУПД, Истина);

		// Вывод подвала накладной
		ОбластьМакета = Макет.ПолучитьОбласть("ПодвалНакладной");
		ОбластьМакета.Параметры.Заполнить(ВыборкаУПД.ДанныеШапки);
		ТабДокумент.Вывести(ОбластьМакета);

		// В табличном документе зададим имя области, в которую был выведен объект.
		// Нужно для возможности печати покомплектно.
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабДокумент,
		НомерСтрокиНачало,СтрокиПечати, СтрШаблон("%1#%2", ВыборкаУПД.Ссылка.УникальныйИдентификатор(), Строка(ВыборкаУПД.НомерСтроки)));

		ЭлементСписка               = ОбъектыПечати.НайтиПоЗначению(ВыборкаУПД.Ссылка);
		ЭлементСписка.Представление = СтрокиПечати[СтрокиПечати.Количество()-1].Представление;

		УправлениеПечатьюБП.ДополнитьДокументПодписьюИПечатью(ТабДокумент, ВыборкаУПД, ОбъектыПечати, ПараметрыПечати);

	КонецЦикла;

	Если МассивОбъектов.Количество() = 1 И ПервыйДокумент Тогда
		СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru='Для %1 универсальный передаточный документ не применяется'"), Строка(МассивОбъектов[0]));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СообщениеОбОшибке);
	КонецЕсли;

	Возврат ТабДокумент;

КонецФункции
