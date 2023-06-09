-- Utilisation de la BDD "3i_in10"
use 3i_in10;

-- Insertion client
INSERT INTO clients (first_name, last_name, mail, password)
VALUES ('Sallyvann', 'ANGE', 'sallyvann.ange@edu.esiee.fr', 'test');
-- On insère un client avec le même nom et prénom, mais différent mail
INSERT INTO clients (first_name, last_name, mail, password)
VALUES ('Sallyvann', 'ANGE', 'sallyvannange@gmail.com', 'test');
-- On insère un autre client
INSERT INTO clients (first_name, last_name, mail, password)
VALUES ('Guillaume', 'Mulier', 'guillaume.mulier@edu.esiee.fr', 'test');
-- On insère un client avec un solde de 200 euros
INSERT INTO clients (first_name, last_name, mail, password, balance)
VALUES ('Térence', 'Barbotin', 'terence.barbotin@edu.esiee.fr', 'test', 200.00);
-- On insère un client avec un total de 10 commandes et un solde de 0 euros
INSERT INTO clients (first_name, last_name, mail, password, offered_count, total_orders)
VALUES ('Minh-Thanh', 'Nguyen', 'minh-thanh.nguyen@edu.esiee.fr', 'test', 1, 10);
-- On insère un client avec un total de 23 commandes et un solde de 0 euros - il n'a jamais utilisé ses pizzas offertes
INSERT INTO clients (first_name, last_name, mail, password, offered_count, total_orders)
VALUES ('Pierre', 'Lefebvre', 'pierre.lefebvre@esiee.fr', 'test', 2, 9);
-- On insère un client avec un total de 13 commandes et un solde de 34,56 euros - il n'a jamais utilisé ses pizzas offertes
INSERT INTO clients (first_name, last_name, mail, password, balance, offered_count, total_orders)
VALUES ('Karim', 'Ali', 'karim.ali@edu.esiee.fr', 'test', 34.56, 1, 2);

-- Insertion Ingrédients
INSERT INTO ingredients (id, name)
VALUES (1,'Sauce tomate'),
       (2,'Fromage'),
       (3,'Jambon'),
       (4,'Olive'),
       (5,'Champignons'),
       (6,'Crème fraiche'),
       (7,'Oeuf'),
       (8,'Merguez'),
       (9,'Viande hachée'),
       (10,'Miel'),
       (11,'Mozzarella'),
       (12,'Chèvre'),
       (13,'Oignons');

-- Insertion Pizzas
INSERT INTO pizzas (id, name, base_price) 
VALUES (1,'Reine', 9.90),
       (2,'Orientale', 10.50),
       (3,'4 Fromages', 11.50),
       (4,'Chèvre miel', 10.50),
       (5,'Marguerita', 7.95);

-- Insertion pizza_ingredients
INSERT INTO pizza_ingredients (pizza_id, ingredient_id)
-- Reine
VALUES (1, 1),
       (1, 11),
       (1, 3),
       (1, 5),
-- Orientale
       (2, 1),
       (2, 8),
       (2, 11),
       (2, 5),
-- 4 Fromages
       (3, 1),
       (3, 2),
       (3, 11),
       (3, 12),
-- Chèvre miel
       (4, 1),
       (4,11),
       (4, 12),
       (4, 10),
-- Marguerita
       (5, 1),
       (5, 11);

-- Insertion sizes
INSERT INTO sizes (id, name, price_ratio) 
VALUES (1, 'naine', 0.67),
       (2, 'humaine', 1),
       (3, 'ogresse', 1.33);

-- Insertion drivers
INSERT INTO drivers (first_name, last_name) 
VALUES ('Emmanuel', 'Macron'),
       ('Elisabeth', 'Borne'),
       ('Gérald', 'Darmanin');

-- Insertion vehicles
INSERT INTO vehicles (type) 
VALUES ('Moto'),
       ('Voiture'),
       ('Voiture'),
       ('Voiture'),
       ('Moto');