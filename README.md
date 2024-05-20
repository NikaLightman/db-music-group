БД для хранения информации о музыкальных группах (участники, туры, концерты, альбомы, песни).
Может быть использована в музыкальных организациях для хранения данных, организации деятельности музыкальных групп.

Особенности:
- в БД в полной мере хранится история участия музыкантов в группах, концертной деятельности, дискографии и другого;
- учитывается возможность нахождения музыканта в составе нескольких групп единовременно;
- учитывается, что альбом может быть совместным для нескольких групп, либо группы могут гостить на альбоме группы-владельца;
- учитывается, что одна песня может быть исполнена несколькими группами (совместная работа, либо кавер, ремикс, например);
- один музыкант (сольный) в данной БД представляет группу из одного человека;
- одна песня (сингл) в данной БД представляет альбом из одной песни;
- атрибут «Владелец» у некоторых промежуточных сущностей имеет тип boolean и является флагом; 
- атрибут «Важность» у некоторых промежуточных таблиц представляет собой число от 0 до 10 (например).
