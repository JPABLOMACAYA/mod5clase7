create table cliente (
	rut varchar(10),
	nombre varchar(50),
	direcci�n varchar(50),
	primary key (rut)
);

create table factura (
	nro_factura int,
	fecha date,
	subtotal int,
	iva int,
	monto_total int,
	rut_cliente varchar(10),	
	primary key (nro_factura),
	foreign key (rut_cliente) references cliente(rut)
);

create table categor�a (
	id int,
	nombre varchar(30),
	descripci�n varchar(60),
	primary key (id)
);

create table producto (
	id int,
	nombre varchar(40),
	descripci�n varchar(60),
	stock int,
	precio_unitario int,
	id_categor�a int,
	primary key (id),
	foreign key (id_categor�a) references categor�a(id)
);

create table factura_producto (
	nro_factura int,
	id_producto int,
	cantidad_producto int,
	valor_total_producto int,
	primary key (nro_factura, id_producto),
	foreign key (nro_factura) references factura(nro_factura),
	foreign key (id_producto) references producto(id)
);

select * from factura_producto;
select * from producto;
select * from categor�a;
select * from factura;
select * from cliente;

insert into cliente values 
	('11111111-2', 'Andr�s Ram�rez', 'Calle 1, Chill�n'),
	('12222222-5', 'Patricio Bustos', 'Pasaje 2, Chill�n'),
	('13333333-k', 'Andr�s Soto', 'Calle 7, Chill�n Viejo');

insert into categor�a values 
	(200301, 'Monitores', 'Monitores de todos los tama�os y marcas'),
	(500101, 'Teclados', 'Teclados de todos los tama�os y marcas');

insert into producto values 
	(200301005, 'Monitor de 20 pulgadas Samsung', 'Pantalla LED Full HD', 50, 2000, 200301),
	(200301007, 'Monitor de 27 pulgadas MSI', 'Pantalla LED UHD', 300, 3000, 200301),
	(200301012, 'Monitor de 22 pulgadas Asus', 'Pantalla LED Full HD', 100, 3500, 200301),
	(500101001, 'Teclado wireless oficina Logitech', 'Teclado inal�mbrico', 80, 45000, 500101),
	(500101002, 'Teclado gamer Corsair', 'Teclado cableado usb', 40, 40000, 500101);

begin;
	insert into factura values (001, '2022-06-15', 85000, 16150, 101150, '11111111-2');
	insert into factura_producto values	(001, 200301005, 10, 20000), (001, 200301007, 10, 30000), (001, 200301012, 10, 35000);
	update producto set stock = stock - 10 where id = 200301005;
	update producto set stock = stock - 10 where id = 200301007;
	update producto set stock = stock - 10 where id = 200301012;
commit;

begin;
	insert into factura values (002, '2022-06-16', 425000, 80750, 505750, '12222222-5');
	insert into factura_producto values	(002, 500101001, 5, 225000), (002, 500101002, 5, 200000);
	update producto set stock = stock - 5 where id = 500101001;
	update producto set stock = stock - 5 where id = 500101002;
commit;

begin;
	insert into factura values (003, '2022-06-18', 60000, 11400, 71400, '13333333-k');
	insert into factura_producto values	(003, 200301007, 20, 60000);
	update producto set stock = stock - 20 where id = 200301007;
commit;

--Item 5
select nombre, monto_total as compra_mayor
from cliente * join factura
on cliente.rut = factura.rut_cliente
where factura.monto_total = (select max(monto_total) from factura);

--Item 6
select nombre, monto_total as compra_m�s_de_60$  --60 es un monto muy bajo, se repetir� m�s abajo con monto m�s grande
from cliente * join factura
on cliente.rut = factura.rut_cliente
where factura.monto_total >= 60;

select nombre, monto_total as compra_m�s_de_$80mil --aqu� se aprecia que logra omitir los montos menores a $80.000.-
from cliente * join factura
on cliente.rut = factura.rut_cliente
where factura.monto_total >= 80000;

--Item 7
-- Primero se agrupa por clientes y se suma el total de unidades que ha comprado cada uno(indistintamente del tipo de producto)
select cliente.nombre, sum(factura_producto.cantidad_producto) as clientes_compran_mas_de_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_5_unid desc;

-- Luego se identifica a los clientes con m�s de 5 unidades compradas totales (en este caso los 3 clientes cumplen el requisito)
select cliente.nombre, sum(factura_producto.cantidad_producto) > 5 as clientes_compran_mas_de_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_5_unid desc;

-- Luego se cuenta a aquellos clientes que cumplieron con el requisito
-- M�todo A (usando condici�n booleana en where y "mayor que" en sum)
select count(clientes_compran_mas_de_5_unid) as cant_clientes_mas_de_5_unids
from (select cliente.nombre, sum(factura_producto.cantidad_producto) > 5 as clientes_compran_mas_de_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_5_unid desc) as tabla_temporal
where clientes_compran_mas_de_5_unid is true;

-- M�todo B (usando s�lo condici�n "mayor que" en where)
select count(clientes_compran_mas_de_5_unid) as cant_clientes_mas_de_5_unids
from (select cliente.nombre, sum(factura_producto.cantidad_producto) as clientes_compran_mas_de_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_5_unid desc) as tabla_temporal
where clientes_compran_mas_de_5_unid > 5;

-- Ejercicio adicional, aumentando las unidades, para que algunos clientes queden fuera.
-- Para el caso de clientes con m�s de 25 unidades compradas totales (en este caso s�lo 1 cliente cumple el requisito)
select cliente.nombre, sum(factura_producto.cantidad_producto) > 25 as clientes_compran_mas_de_25_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_25_unid desc;

-- Luego se cuenta a aquellos clientes que cumplieron con el requisito
-- M�todo A (usando condici�n booleana en where y "mayor que" en sum)
select count(clientes_compran_mas_de_25_unid) as cant_clientes_mas_de_25_unids
from (select cliente.nombre, sum(factura_producto.cantidad_producto) > 25 as clientes_compran_mas_de_25_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_25_unid desc) as tabla_temporal
where clientes_compran_mas_de_25_unid is true;

-- M�todo B (usando s�lo condici�n "mayor que" en where)
select count(clientes_compran_mas_de_25_unid) as cant_clientes_mas_de_25_unids
from (select cliente.nombre, sum(factura_producto.cantidad_producto) as clientes_compran_mas_de_25_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_25_unid desc) as tabla_temporal
where clientes_compran_mas_de_25_unid > 25;

/*
Otros intentos de soluciones--->

select cliente.nombre, sum(factura_producto.cantidad_producto) as unidades_compradas from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by unidades_compradas desc;

select count(cliente.nombre) as nro_clientes_mas_5_unidades from cliente;

select count(cliente.nombre) from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
where factura_producto.cantidad_producto > 10

select cliente.nombre, (select sum(factura_producto.cantidad_producto) as unidades_compradas) from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by unidades_compradas desc;

select cliente.nombre, count(factura_producto.cantidad_producto) as compras_mayores_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
where cantidad_producto > 5
group by cliente.nombre
order by compras_mayores_5_unid desc;

select sum(factura_producto.cantidad_producto), count(cliente.nombre) as clientes_compran_mas_de_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
where cantidad_producto > 5
group by cliente.nombre
order by clientes_compran_mas_de_5_unid desc;

/*
--Estas facturas deben ingresarse mediante transacciones, por lo tanto se ver� afectado el stock de cada producto
insert into factura values 
	(001, '2022-06-15', 85000, 16150, 101150, '11111111-2'),
	(002, '2022-06-16', 425000, 80750, 505750, '12222222-5'),
	(003, '2022-06-18', 60000, 11400, 71400, '13333333-k');
	
insert into factura_producto values 
	(001, 200301005, 10, 20000),
	(001, 200301007, 10, 30000),
	(001, 200301012, 10, 35000),
	(002, 500101001, 5, 225000),
	(002, 500101002, 5, 200000),
	(003, 200301007, 20, 60000);
*/

-- Otro ejemplo de transacciones. A�n se podr�a pulir m�s, por ej. utilizando la funci�n SUM en los totales de c/producto
--para obtener el subtotal de la factura. 
begin;
	insert into factura values (001, '2022-06-15', null, null, null, null);
	insert into factura_producto values	(001, 200301005, 10, (select producto.precio_unitario from producto where producto.id = 200301005)*10), (001, 200301007, 10, (select producto.precio_unitario from producto where producto.id = 200301007)*10), (001, 200301012, 10, (select producto.precio_unitario from producto where producto.id = 200301012)*10);
	update factura set rut_cliente = '11111111-2' where nro_factura = 001;
	update producto set stock = stock - 10 where id = 200301005;
	update producto set stock = stock - 10 where id = 200301007;
	update producto set stock = stock - 10 where id = 200301012;
commit;
*/
--falta insertar inicialmente a la factura s�lo el id y el cliente, lo dem�s null.
--luego de insertar valores a factura_producto, realizar update a factura con los valores faltantes faltantes
--para hacer lo anterior. primero deber� realizar delete a los datos ya ingresados en ambas tablas involucradas

/*
drop table factura_producto;
drop table producto;
drop table categor�a;
delete from factura;
drop table factura;
drop table cliente;
*/