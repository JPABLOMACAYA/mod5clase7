create table cliente (
	rut varchar(10),
	nombre varchar(50),
	dirección varchar(50),
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

create table categoría (
	id int,
	nombre varchar(30),
	descripción varchar(60),
	primary key (id)
);

create table producto (
	id int,
	nombre varchar(40),
	descripción varchar(60),
	stock int,
	precio_unitario int,
	id_categoría int,
	primary key (id),
	foreign key (id_categoría) references categoría(id)
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
select * from categoría;
select * from factura;
select * from cliente;

insert into cliente values 
	('11111111-2', 'Andrés Ramírez', 'Calle 1, Chillán'),
	('12222222-5', 'Patricio Bustos', 'Pasaje 2, Chillán'),
	('13333333-k', 'Andrés Soto', 'Calle 7, Chillán Viejo');

insert into categoría values 
	(200301, 'Monitores', 'Monitores de todos los tamaños y marcas'),
	(500101, 'Teclados', 'Teclados de todos los tamaños y marcas');

insert into producto values 
	(200301005, 'Monitor de 20 pulgadas Samsung', 'Pantalla LED Full HD', 50, 2000, 200301),
	(200301007, 'Monitor de 27 pulgadas MSI', 'Pantalla LED UHD', 300, 3000, 200301),
	(200301012, 'Monitor de 22 pulgadas Asus', 'Pantalla LED Full HD', 100, 3500, 200301),
	(500101001, 'Teclado wireless oficina Logitech', 'Teclado inalámbrico', 80, 45000, 500101),
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
select nombre, monto_total as compra_más_de_60$  --60 es un monto muy bajo, se repetirá más abajo con monto más grande
from cliente * join factura
on cliente.rut = factura.rut_cliente
where factura.monto_total >= 60;

select nombre, monto_total as compra_más_de_$80mil --aquí se aprecia que logra omitir los montos menores a $80.000.-
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

-- Luego se identifica a los clientes con más de 5 unidades compradas totales (en este caso los 3 clientes cumplen el requisito)
select cliente.nombre, sum(factura_producto.cantidad_producto) > 5 as clientes_compran_mas_de_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_5_unid desc;

-- Luego se cuenta a aquellos clientes que cumplieron con el requisito
-- Método A (usando condición booleana en where y "mayor que" en sum)
select count(clientes_compran_mas_de_5_unid) as cant_clientes_mas_de_5_unids
from (select cliente.nombre, sum(factura_producto.cantidad_producto) > 5 as clientes_compran_mas_de_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_5_unid desc) as tabla_temporal
where clientes_compran_mas_de_5_unid is true;

-- Método B (usando sólo condición "mayor que" en where)
select count(clientes_compran_mas_de_5_unid) as cant_clientes_mas_de_5_unids
from (select cliente.nombre, sum(factura_producto.cantidad_producto) as clientes_compran_mas_de_5_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_5_unid desc) as tabla_temporal
where clientes_compran_mas_de_5_unid > 5;

-- Ejercicio adicional, aumentando las unidades, para que algunos clientes queden fuera.
-- Para el caso de clientes con más de 25 unidades compradas totales (en este caso sólo 1 cliente cumple el requisito)
select cliente.nombre, sum(factura_producto.cantidad_producto) > 25 as clientes_compran_mas_de_25_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_25_unid desc;

-- Luego se cuenta a aquellos clientes que cumplieron con el requisito
-- Método A (usando condición booleana en where y "mayor que" en sum)
select count(clientes_compran_mas_de_25_unid) as cant_clientes_mas_de_25_unids
from (select cliente.nombre, sum(factura_producto.cantidad_producto) > 25 as clientes_compran_mas_de_25_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_25_unid desc) as tabla_temporal
where clientes_compran_mas_de_25_unid is true;

-- Método B (usando sólo condición "mayor que" en where)
select count(clientes_compran_mas_de_25_unid) as cant_clientes_mas_de_25_unids
from (select cliente.nombre, sum(factura_producto.cantidad_producto) as clientes_compran_mas_de_25_unid from factura
join factura_producto on factura.nro_factura = factura_producto.nro_factura
join cliente on cliente.rut = factura.rut_cliente
group by cliente.nombre
order by clientes_compran_mas_de_25_unid desc) as tabla_temporal
where clientes_compran_mas_de_25_unid > 25;
