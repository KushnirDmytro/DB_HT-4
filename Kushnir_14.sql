DROP DATABASE Building_company;

CREATE DATABASE Building_company
CHARACTER SET utf8
COLLATE utf8_general_ci;

USE Building_company;


CREATE TABLE measurement_units (
    units_noution VARCHAR(10) PRIMARY KEY
)  ENGINE=INNODB CHARACTER SET=DEFAULT;
;


CREATE TABLE materials_and_works (
    notion VARCHAR(20) PRIMARY KEY NOT NULL,
    units VARCHAR(10) NULL DEFAULT 'Одиниць',
    price_per_unit DOUBLE NOT NULL DEFAULT 0.0,
    CONSTRAINT FK_materials_and_works_name FOREIGN KEY (units)
        REFERENCES measurement_units (units_noution)
        ON DELETE SET NULL ON UPDATE CASCADE
)  ENGINE=INNODB CHARACTER SET=DEFAULT;
;


CREATE TABLE clients (
    client_name VARCHAR(20) NOT NULL DEFAULT 'Безіменний',
    client_surname VARCHAR(30) NOT NULL DEFAULT 'Анонім',
    name_and_surname varchar(51) 
    AS (CONCAT(client_name , ' ' , client_surname)) stored unique NOT NULL ,
    -- не знайшов іншого способу щоб використати ім'я та прізвище в ролі зовнішнього ключа
    client_address VARCHAR(255) NOT NULL,
    client_phone_number BIGINT(10) NULL,
    
    CONSTRAINT PK_name_surname
    PRIMARY KEY (client_name, client_surname)
)  ENGINE=INNODB CHARACTER SET=DEFAULT;
;


create table Estimates
(
task_ID INT, 
order_ID INT, 
resourse_type varchar(10),
resourse_ammount double,
resourse_cost double, 
estimate_value double AS (resourse_ammount * resourse_cost) virtual 
);




CREATE TABLE Orders (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_date DATE NOT NULL,
    project_name CHAR(20) NOT NULL DEFAULT 'UNKNOWN',
    description TEXT NULL,
    object_photo BLOB NULL,
  --  total_price INT(10) AS (sum(select price from  ))   ZEROFILL NOT NULL DEFAULT 0,
    Orderer VARCHAR(51) NOT NULL default 'UNKNOWN',
    Final_date DATE NULL,
    Real_final_date DATE NULL,
    
    constraint FK_Orderer foreign key (orderer)references
    clients(name_and_surname)
    ON UPDATE CASCADE
    
    
)  ENGINE=INNODB CHARACTER SET=DEFAULT;



CREATE TABLE tasks (
    task_ID INT AUTO_INCREMENT PRIMARY KEY,
    Orderer VARCHAR(51) NULL DEFAULT 'Безіменний',
    ORDER_ID INT,
    resourse_type VARCHAR(20) NULL,
    resourse_quantity DOUBLE,
    CONSTRAINT FK_client_name FOREIGN KEY (Orderer)
        REFERENCES clients (name_and_surname)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT FOREIGN KEY (ORDER_ID)
        REFERENCES Orders (ID)
        ON UPDATE CASCADE ON DELETE NO ACTION
)  ENGINE=INNODB CHARACTER SET=DEFAULT;
;

DELIMITER //
create trigger positive_prices
BEFORE INSERT
ON materials_and_works FOR EACH ROW
BEGIN
IF (new.price_per_unit <= 0.0)
then SIGNAL sqlstate '45000'
set message_text = 'CHECK ERROR inserting negative price';
end If;
END//
DELIMITER ;

DELIMITER //
create trigger orders_dates_not_in_future
BEFORE INSERT
ON Orders FOR EACH ROW
BEGIN
IF (new.Order_date > now())
then SIGNAL sqlstate '45000'
set message_text = 'CHECK ERROR inserting date later than today';
end If;
END//
DELIMITER ;

INSERT INTO measurement_units (units_noution)
Values ('кг'),('літр'),('люд\год'),('тонн'),('год'),('$'),('шт'),('тис'),('кв.м.');

INSERT INTO materials_and_works (notion, units, price_per_unit)
Values ('побілка', 'кв.м.' , 10.0 ), 
('покраска', 'кв.м.' , 12.0),
 ('фарба', 'літр',  150.0),
 ('охорона', 'люд\год', 20.0 ),
('цегла', 'тис' , 1000.0 ),
('паркет','кв.м.' , 1500.0),
('штраф за цеглу','$' , 200.0);



INSERT INTO clients (client_name, client_surname,
 client_address, client_phone_number)
Values ('Іван', 'Іваненко' , 'вул.Бендери 21, кв. 10', 0612543120), 
('Петро', 'Петренко' , 'вул.Литовська 20, кв. 11', 0644523650),
('Тарас', 'Тарасенко' , 'вул.Бендери 121, кв. 21', 0644523120),
('Софія', 'Мудра' , 'вул.Бендери 221, кв. 125', 0644522340),
('Сара', 'Штольц' , 'вул.Соборна 21 (буд)', 0644524330),
('Абдулла', 'Вангамішелійманов' , 'вул.Стрийська 22, кв. 110', 0644511120),
(default, default, 'вул.Зеленаname 25, кв. 110', 0644511120);



INSERT INTO orders (Order_date, project_name,
 description, object_photo, Orderer, Final_date, Real_final_date)
Values ('2014-04-11', 'Avalon 5' , 'папитка номэр 5' , NULL, 'Абдулла Вангамішелійманов', '2014-04-11', '2014-04-11'),
('2012-04-11', 'Avalon 4' , 'ну тепер точно не впаде' , NULL, 'Іван Іваненко', '2014-04-11', '2014-04-11'),
('2011-04-11', 'Avalon 3' , 'Бог любить трійцю' , NULL, 'Іван Іваненко', '2014-04-11', '2014-04-11'),
('2011-06-22', 'Avalon 2' , 'вам краще не знати що сталося з першим' , NULL, 'Іван Іваненко', '2014-04-11', '2014-04-11');

INSERT INTO tasks (Orderer,
ORDER_ID,
resourse_type,
resourse_quantity)
Values ('Абдулла Вангамішелійманов', 1, 'покраска', 150.0),
('Абдулла Вангамішелійманов', 2, 'паркет', 150.0),
('Іван Іваненко', 4, 'паркет', 220.0),
('Іван Іваненко', 1, 'цегла', 25.1),
('Іван Іваненко', 1, 'штраф за цеглу', 150.0),
('Безіменний Анонім', 1, 'охорона', 200.0);


 /*
 CONSTRAINS :
 Prices should be positive
 orders date should not be later than todays
*/