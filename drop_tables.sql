use 3i_in10;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS pizzas;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS pizza_ingredients;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS sizes;

DROP TRIGGER IF EXISTS update_order_amount;
DROP PROCEDURE IF EXISTS get_orders_average;
DROP PROCEDURE IF EXISTS get_clients_by_total_orders;
DROP PROCEDURE IF EXISTS get_orders_count_by_client;
DROP PROCEDURE IF EXISTS get_average_orders_by_client;
DROP PROCEDURE IF EXISTS get_unused_vehicles;
DROP PROCEDURE IF EXISTS get_clients_with_more_orders_than_average;




SET FOREIGN_KEY_CHECKS = 1;