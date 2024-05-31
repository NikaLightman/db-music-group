-- Продюсер
CREATE TABLE producer (
    id 				BIGSERIAL,
    surname 		TEXT NOT NULL,
    name 			TEXT NOT NULL,
    patronymic 		TEXT NULL,
    passport_data 	TEXT NOT NULL,
    date_of_birth 	DATE NOT NULL,
    tin 			TEXT NOT NULL -- ИНН
);

ALTER TABLE producer
ADD CONSTRAINT pk_producer 
PRIMARY KEY (id);

ALTER TABLE producer
ADD CONSTRAINT uniq_tin_producer
UNIQUE (tin);

ALTER TABLE producer
ADD CONSTRAINT uniq_passport_data_producer
UNIQUE (passport_data);

ALTER TABLE producer
ADD CONSTRAINT chk_passport_data_producer
CHECK (passport_data ~ '^[0-9]{4}\s[0-9]{6}$');

ALTER TABLE producer
ADD CONSTRAINT chk_date_of_birth_producer 
CHECK (date_of_birth <= CURRENT_DATE);

ALTER TABLE producer
ADD CONSTRAINT chk_tin_producer
CHECK (tin ~ '^[0-9]{10}$' OR tin ~ '^[0-9]{12}$');


-- Страна
CREATE TABLE country (
    id 				BIGSERIAL,
    name 			TEXT NOT NULL
);

ALTER TABLE country
ADD CONSTRAINT pk_country 
PRIMARY KEY (id);

ALTER TABLE country
ADD CONSTRAINT uniq_name_country
UNIQUE (name);


-- Город
CREATE TABLE city (
    id 				BIGSERIAL,
    country_id 		BIGINT NOT NULL,
    name 			TEXT NOT NULL,
    location_info 	TEXT NOT NULL -- Информация о расположении города
);

ALTER TABLE city
ADD CONSTRAINT pk_city
PRIMARY KEY (id);

ALTER TABLE city
ADD CONSTRAINT fk_city_country
FOREIGN KEY (country_id) REFERENCES country(id)
ON DELETE CASCADE;

-- Альтернативный ключ
ALTER TABLE city
ADD CONSTRAINT uniq_key_group_city
UNIQUE (country_id, name);


-- Группа
CREATE TABLE music_group (
    id 						BIGSERIAL,
    country_of_origin_id 	BIGINT NOT NULL,
    name 					TEXT NOT NULL,
    start_date 				DATE NOT NULL,
    end_date 				DATE NULL
);

ALTER TABLE music_group
ADD CONSTRAINT pk_music_group
PRIMARY KEY (id);

ALTER TABLE music_group
ADD CONSTRAINT fk_music_group_country
FOREIGN KEY (country_of_origin_id) REFERENCES country(id)
ON DELETE CASCADE;

ALTER TABLE music_group
ADD CONSTRAINT uniq_name_music_group
UNIQUE (name);

ALTER TABLE music_group 
ADD CONSTRAINT chk_start_date_music_group
CHECK (start_date <= CURRENT_DATE);

-- Предполагается, что у группы нет заранее фиксированной даты распада.
-- То есть при внесении в базу данных действующей группы,
-- дата распада должна быть меньше или равна текущей дате.
ALTER TABLE music_group 
ADD CONSTRAINT chk_end_date_music_group
CHECK (end_date IS NULL OR
	(end_date <= CURRENT_DATE AND end_date >= start_date));


-- Продюсер группы
CREATE TABLE producer_of_group (
    id 						BIGSERIAL,
    group_id 				BIGINT NOT NULL,
    producer_id 			BIGINT NOT NULL,
    start_date 				DATE NOT NULL,
    end_date 				DATE NULL
);

ALTER TABLE producer_of_group
ADD CONSTRAINT pk_producer_of_group
PRIMARY KEY (id);

ALTER TABLE producer_of_group
ADD CONSTRAINT fk_producer_of_group_music_group
FOREIGN KEY (group_id) REFERENCES music_group(id)
ON DELETE CASCADE;

ALTER TABLE producer_of_group
ADD CONSTRAINT fk_producer_of_group_producer
FOREIGN KEY (producer_id) REFERENCES producer(id)
ON DELETE CASCADE;

ALTER TABLE producer_of_group 
ADD CONSTRAINT chk_start_date_producer_of_group
CHECK (start_date <= CURRENT_DATE);

ALTER TABLE producer_of_group 
ADD CONSTRAINT chk_end_date_producer_of_group
CHECK (end_date IS NULL OR end_date >= start_date);

-- Альтернативный ключ
ALTER TABLE producer_of_group
ADD CONSTRAINT uniq_key_group_producer_of_group
UNIQUE (group_id, producer_id, start_date);


-- Жанр
CREATE TABLE genre (
    id 					BIGSERIAL,
    name 				TEXT NOT NULL
);

ALTER TABLE genre
ADD CONSTRAINT pk_genre
PRIMARY KEY (id);

ALTER TABLE genre
ADD CONSTRAINT uniq_name_genre
UNIQUE (name);


-- Жанр группы
CREATE TABLE genre_of_group (
    id 					BIGSERIAL,
    genre_id 			BIGINT NOT NULL,
    group_id 			BIGINT NOT NULL,
    importance 			INT NOT NULL -- Важность по 10-балльной шкале
);

ALTER TABLE genre_of_group
ADD CONSTRAINT pk_genre_of_group
PRIMARY KEY (id);

ALTER TABLE genre_of_group
ADD CONSTRAINT fk_genre_of_group_genre
FOREIGN KEY (genre_id) REFERENCES genre(id)
ON DELETE CASCADE;

ALTER TABLE genre_of_group
ADD CONSTRAINT fk_genre_of_group_music_group
FOREIGN KEY (group_id) REFERENCES music_group(id)
ON DELETE CASCADE;

ALTER TABLE genre_of_group
ADD CONSTRAINT chk_importance_genre_of_group
CHECK (importance BETWEEN 1 AND 10);

-- Альтернативный ключ
ALTER TABLE genre_of_group
ADD CONSTRAINT uniq_key_group_genre_of_group
UNIQUE (genre_id, group_id);


-- Музыкант
CREATE TABLE musician (
    id 					BIGSERIAL,
    main_genre_id 		BIGINT NOT NULL,
    city_of_birth_id 	BIGINT NOT NULL,
    surname 			TEXT NOT NULL,
    name 				TEXT NOT NULL,
    patronymic 			TEXT NULL,
    date_of_birth 		DATE NOT NULL,
    passport_data 		TEXT NOT NULL
);

ALTER TABLE musician
ADD CONSTRAINT pk_musician
PRIMARY KEY (id);

ALTER TABLE musician
ADD CONSTRAINT fk_musician_genre
FOREIGN KEY (main_genre_id) REFERENCES genre(id)
ON DELETE CASCADE;

ALTER TABLE musician
ADD CONSTRAINT fk_musician_city
FOREIGN KEY (city_of_birth_id) REFERENCES city(id)
ON DELETE CASCADE;

ALTER TABLE musician
ADD CONSTRAINT uniq_passport_data_musician
UNIQUE (passport_data);

ALTER TABLE musician
ADD CONSTRAINT chk_passport_data_musician
CHECK (passport_data ~ '^[0-9]{4}\s[0-9]{6}$');

ALTER TABLE musician
ADD CONSTRAINT chk_date_of_birth_musician 
CHECK (date_of_birth <= CURRENT_DATE);


-- Участник группы
CREATE TABLE group_member (
    id 					BIGSERIAL,
    musician_id 		BIGINT NOT NULL,
    group_id 			BIGINT NOT NULL,
    start_date 			DATE NOT NULL,
    end_date 			DATE NULL,
    nickname 			TEXT NULL,
    is_leader 			BOOLEAN NOT NULL -- Лидер группы или нет
);

ALTER TABLE group_member
ADD CONSTRAINT pk_group_member
PRIMARY KEY (id);

ALTER TABLE group_member
ADD CONSTRAINT fk_group_member_musician
FOREIGN KEY (musician_id) REFERENCES musician(id)
ON DELETE CASCADE;

ALTER TABLE group_member
ADD CONSTRAINT fk_group_member_music_group
FOREIGN KEY (group_id) REFERENCES music_group(id)
ON DELETE CASCADE;

ALTER TABLE group_member
ADD CONSTRAINT chk_start_date_group_member
CHECK (start_date <= CURRENT_DATE);

ALTER TABLE group_member 
ADD CONSTRAINT chk_end_date_group_member
CHECK (end_date IS NULL OR end_date >= start_date);

-- Альтернативный ключ
ALTER TABLE group_member
ADD CONSTRAINT uniq_key_group_group_member
UNIQUE (musician_id, group_id, start_date);


-- Класс инструмента
CREATE TABLE instrument_class (
    id 					BIGSERIAL,
    name 				TEXT NOT NULL
);

ALTER TABLE instrument_class
ADD CONSTRAINT pk_instrument_class
PRIMARY KEY (id);

ALTER TABLE instrument_class
ADD CONSTRAINT uniq_name_instrument_class
UNIQUE (name);


-- Инструмент
CREATE TABLE instrument (
    id 					BIGSERIAL,
    name 				TEXT NOT NULL,
    class_id 			BIGINT NOT NULL
);

ALTER TABLE instrument
ADD CONSTRAINT pk_instrument
PRIMARY KEY (id);

ALTER TABLE instrument
ADD CONSTRAINT fk_instrument_instrument_class
FOREIGN KEY (class_id) REFERENCES instrument_class(id)
ON DELETE CASCADE;

-- Альтернативный ключ
ALTER TABLE instrument
ADD CONSTRAINT uniq_key_group_instrument
UNIQUE (name, class_id);


-- Инструмент музыканта
CREATE TABLE musician_instrument (
    id 					BIGSERIAL,
    instrument_id		BIGINT NOT NULL,    
    musician_id 		BIGINT NOT NULL,
    importance 			INT NOT NULL  -- Важность по 10-балльной шкале
);

ALTER TABLE musician_instrument
ADD CONSTRAINT pk_musician_instrument
PRIMARY KEY (id);

ALTER TABLE musician_instrument
ADD CONSTRAINT fk_musician_instrument_instrument
FOREIGN KEY (instrument_id) REFERENCES instrument(id)
ON DELETE CASCADE;

ALTER TABLE musician_instrument
ADD CONSTRAINT fk_musician_instrument_musician
FOREIGN KEY (musician_id) REFERENCES musician(id)
ON DELETE CASCADE;

ALTER TABLE musician_instrument
ADD CONSTRAINT chk_importance_musician_instrument
CHECK (importance BETWEEN 1 AND 10);

-- Альтернативный ключ
ALTER TABLE musician_instrument
ADD CONSTRAINT uniq_key_group_musician_instrument
UNIQUE (instrument_id, musician_id);


-- Альбом
CREATE TABLE album (
    id 					BIGSERIAL,
    name 				TEXT NOT NULL,
    release_date 		DATE NOT NULL,
    duration 			TIME NOT NULL,
    description 		TEXT NULL
);

ALTER TABLE album
ADD CONSTRAINT pk_album
PRIMARY KEY (id);

ALTER TABLE album
ADD CONSTRAINT uniq_name_album
UNIQUE (name);

ALTER TABLE album
ADD CONSTRAINT chk_release_date_album 
CHECK (release_date <= CURRENT_DATE);


-- Жанр альбома
CREATE TABLE genre_of_album (
    id 					BIGSERIAL,
    genre_id 			BIGINT NOT NULL,
    album_id 			BIGINT NOT NULL,
    importance 			INT NOT NULL -- Важность по 10-балльной шкале
);

ALTER TABLE genre_of_album
ADD CONSTRAINT pk_genre_of_album
PRIMARY KEY (id);

ALTER TABLE genre_of_album
ADD CONSTRAINT fk_genre_of_album_genre
FOREIGN KEY (genre_id) REFERENCES genre(id)
ON DELETE CASCADE;

ALTER TABLE genre_of_album
ADD CONSTRAINT fk_genre_of_album_album
FOREIGN KEY (album_id) REFERENCES album(id)
ON DELETE CASCADE;

ALTER TABLE genre_of_album
ADD CONSTRAINT chk_importance_genre_of_album
CHECK (importance BETWEEN 1 AND 10);

-- Альтернативный ключ
ALTER TABLE genre_of_album
ADD CONSTRAINT uniq_key_group_genre_of_album
UNIQUE (genre_id, album_id);


-- Группа на альбоме
CREATE TABLE group_on_album (
    id 					BIGSERIAL,
    group_id 			BIGINT NOT NULL,
    album_id 			BIGINT NOT NULL,
    is_owner 			BOOLEAN NOT NULL -- Владелец альбома или гость
);

ALTER TABLE group_on_album
ADD CONSTRAINT pk_group_on_album
PRIMARY KEY (id);

ALTER TABLE group_on_album
ADD CONSTRAINT fk_group_on_album_music_group
FOREIGN KEY (group_id) REFERENCES music_group(id)
ON DELETE CASCADE;

ALTER TABLE group_on_album
ADD CONSTRAINT fk_group_on_album_album
FOREIGN KEY (album_id) REFERENCES album(id)
ON DELETE CASCADE;

-- Альтернативный ключ
ALTER TABLE group_on_album
ADD CONSTRAINT uniq_key_group_group_on_album
UNIQUE (group_id, album_id);


-- Песня
CREATE TABLE song (
    id 					BIGSERIAL,
    name 				TEXT NOT NULL,
    creation_date 		DATE NOT NULL,
    duration 			TIME NOT NULL,
    description 		TEXT NULL
);

ALTER TABLE song
ADD CONSTRAINT pk_song
PRIMARY KEY (id);

ALTER TABLE song
ADD CONSTRAINT chk_creation_date_song
CHECK (creation_date <= CURRENT_DATE);


-- Жанр песни
CREATE TABLE genre_of_song (
    id 					BIGSERIAL,
    genre_id 			BIGINT NOT NULL,
    song_id 			BIGINT NOT NULL,
    importance 			INT NOT NULL -- Важность по 10-балльной шкале
);

ALTER TABLE genre_of_song
ADD CONSTRAINT pk_genre_of_song
PRIMARY KEY (id);

ALTER TABLE genre_of_song
ADD CONSTRAINT fk_genre_of_song_genre
FOREIGN KEY (genre_id) REFERENCES genre(id)
ON DELETE CASCADE;

ALTER TABLE genre_of_song
ADD CONSTRAINT fk_genre_of_song_song
FOREIGN KEY (song_id) REFERENCES song(id)
ON DELETE CASCADE;

ALTER TABLE genre_of_song
ADD CONSTRAINT chk_importance_genre_of_song
CHECK (importance BETWEEN 1 AND 10);

-- Альтернативный ключ
ALTER TABLE genre_of_song
ADD CONSTRAINT uniq_key_group_genre_of_song
UNIQUE (genre_id, song_id);


-- Тур
CREATE TABLE tour (
    id 					BIGSERIAL,
    name 				TEXT NOT NULL,
    start_date 			DATE NOT NULL, -- Начало тура может быть запланировано заранее
    end_date 			DATE NOT NULL, -- У тура в отличие от контрактов (бессрочный) точно есть конец
    description 		TEXT NULL
);

ALTER TABLE tour
ADD CONSTRAINT pk_tour
PRIMARY KEY (id);

ALTER TABLE tour 
ADD CONSTRAINT chk_end_date_tour
CHECK (end_date >= start_date);


-- Группа в туре
CREATE TABLE group_in_tour (
    id 					BIGSERIAL,
    group_id 			BIGINT NOT NULL,
    tour_id 			BIGINT NOT NULL,
    is_owner 			BOOLEAN NOT NULL -- Группа-владелец тура или гость
);

ALTER TABLE group_in_tour
ADD CONSTRAINT pk_group_in_tour
PRIMARY KEY (id);

ALTER TABLE group_in_tour
ADD CONSTRAINT fk_group_in_tour_music_group
FOREIGN KEY (group_id) REFERENCES music_group(id)
ON DELETE CASCADE;

ALTER TABLE group_in_tour
ADD CONSTRAINT fk_group_in_tour_tour
FOREIGN KEY (tour_id) REFERENCES tour(id)
ON DELETE CASCADE;

-- Альтернативный ключ
ALTER TABLE group_in_tour
ADD CONSTRAINT uniq_key_group_group_in_tour
UNIQUE (group_id, tour_id);


-- Концерт
CREATE TABLE concert (
    id 					BIGSERIAL,
    tour_id 			BIGINT NOT NULL,
    city_id 			BIGINT NOT NULL,
    start_date 			TIMESTAMP NOT NULL, -- Начало концерта может быть запланировано заранее
    end_date 			TIMESTAMP NOT NULL, -- У концерта в отличие от контрактов (бессрочный) точно есть конец
    duration 			TIME NOT NULL,
    location_info 		TEXT NOT NULL -- Информация о расположении
);

ALTER TABLE concert
ADD CONSTRAINT pk_concert
PRIMARY KEY (id);

ALTER TABLE concert
ADD CONSTRAINT fk_concert_tour
FOREIGN KEY (tour_id) REFERENCES tour(id)
ON DELETE CASCADE;

ALTER TABLE concert
ADD CONSTRAINT fk_concert_city
FOREIGN KEY (city_id) REFERENCES city(id)
ON DELETE CASCADE;

ALTER TABLE concert
ADD CONSTRAINT chk_end_date_concert
CHECK (end_date >= start_date);

-- Альтернативный ключ
ALTER TABLE concert
ADD CONSTRAINT uniq_key_group_concert
UNIQUE (tour_id, city_id, start_date);


-- Группа на песне
CREATE TABLE group_on_song (
    id 					BIGSERIAL,
    song_id 			BIGINT NOT NULL,
    group_id 			BIGINT NOT NULL,
    is_owner 		    BOOLEAN NOT NULL -- Группа-владелец песни или гость
);

ALTER TABLE group_on_song
ADD CONSTRAINT pk_group_on_song
PRIMARY KEY (id);

ALTER TABLE group_on_song
ADD CONSTRAINT fk_group_on_song_song
FOREIGN KEY (song_id) REFERENCES song(id)
ON DELETE CASCADE;

ALTER TABLE group_on_song
ADD CONSTRAINT fk_group_on_song_music_group
FOREIGN KEY (group_id) REFERENCES music_group(id)
ON DELETE CASCADE;

-- Альтернативный ключ
ALTER TABLE group_on_song
ADD CONSTRAINT uniq_key_group_group_on_song
UNIQUE (song_id, group_id);


-- Песня на альбоме
CREATE TABLE song_on_album (
    id 					BIGSERIAL,
    song_id 			BIGINT NOT NULL,
    album_id 			BIGINT NOT NULL,
    song_number 		INT NULL -- Номер песни на альбоме указывать необязательно
);

ALTER TABLE song_on_album
ADD CONSTRAINT pk_song_on_album
PRIMARY KEY (id);

ALTER TABLE song_on_album
ADD CONSTRAINT fk_song_on_album_song
FOREIGN KEY (song_id) REFERENCES song(id)
ON DELETE CASCADE;

ALTER TABLE song_on_album
ADD CONSTRAINT fk_song_on_album_album
FOREIGN KEY (album_id) REFERENCES album(id)
ON DELETE CASCADE;

ALTER TABLE song_on_album
ADD CONSTRAINT chk_song_number_song_on_album
CHECK (song_number IS NULL OR song_number > 0);

-- Альтернативный ключ
ALTER TABLE song_on_album
ADD CONSTRAINT uniq_key_group_song_on_album
UNIQUE (song_id, album_id);
