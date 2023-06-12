-- Utilisation de la BDD "3i_in10"
use 3i_in10;

ALTER DATABASE 3i_in10 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Création de la table "pizzas", qui contiendra l'ensemble des pizzas disponibles au menu
CREATE TABLE IF NOT EXISTS pizzas (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    base_price DECIMAL(10,2) NOT NULL
);

-- Création de la table "ingredients" qui contiendra l'ensemble des ingrédients pouvant faire parti d'une pizza
CREATE TABLE IF NOT EXISTS ingredients (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Création d'une table de liaison "pizza_ingredients" permettant d'associer les pizzas à leurs ingrédients
CREATE TABLE IF NOT EXISTS pizza_ingredients (
    pizza_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    -- On s'assure en assignant la clé primaire aux deux colonnes "pizza_id" et "ingredient_id" que chaque combinaison pizza/ingredient est unique dans la table
    UNIQUE (pizza_id, ingredient_id),
    -- On assigne les clés étrangères, provenant des tables "pizzas" et "ingredients"
    FOREIGN KEY (pizza_id) REFERENCES pizzas(id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
);

-- Création de la table "sizes" qui contiendra l'ensemble des tailles de pizzas disponibles
CREATE TABLE IF NOT EXISTS sizes (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    price_ratio DECIMAL(10,2) NOT NULL
);

-- Création de la table "vehicles" qui stockera l'ensemble des véhicules de la flotte
CREATE TABLE IF NOT EXISTS vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type ENUM('Moto','Voiture') NOT NULL -- Moto ou voiture ?
);

-- Création de la table "clients" qui contiendra l'ensemble des informations utiles sur le client (nom, prénom, email, solde, nombre de pizzas commandées).
-- On pourrait ajouter une colonne comme "postal_adress" mais ce n'est pas vraiment utile au vu du cahier des charges demandé. Nom, prénom et email ne le sont pas vraiment non plus.
CREATE TABLE IF NOT EXISTS clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    mail VARCHAR(255) NOT NULL UNIQUE, -- Contrainte d'unicité pour être sûr qu'un même client ne s'est pas enregistré 2 fois avec le même mail
    balance DECIMAL(10,2) DEFAULT 0.00, -- On met le solde par défaut à 0.00 €
    offered_count INT DEFAULT 0, -- Nombre de pizzas offertes
    total_orders INT DEFAULT 0, -- On met le nombre de commande par défaut à 0
    password VARCHAR(255) NOT NULL -- Mdp utilisateur
);

-- Création de la table "admins" qui permettra de stocker les utilisateurs ayant les habilités nécessaires pour gérer les commandes, voir les utilisateurs, etc.
CREATE TABLE IF NOT EXISTS admins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    mail VARCHAR(255) NOT NULL UNIQUE, -- Contrainte d'unicité pour être sûr qu'un même admin ne s'est pas enregistré 2 fois avec le même mail
    password VARCHAR(255) NOT NULL -- Mdp admin
);

-- Création de la table "drivers" qui stockera des informations sur les livreurs
CREATE TABLE IF NOT EXISTS drivers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

-- Création de la table "orders" pour enregistrer l'ensemble des commandes
CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    pizza_id INT NOT NULL,
    size_id INT NOT NULL,
    amount DECIMAL(10, 2),
    driver_id INT,
    vehicle_id INT,
    status ENUM('En cours','Livré', 'Annulé') DEFAULT 'En cours',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Permet de récupérer l'heure à laquelle la commande a été livrée. Elle enregistre aussi l'heure à laquelle la commande est annulée et créée mais c'est moins utile
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (pizza_id) REFERENCES pizzas(id),
    FOREIGN KEY (size_id) REFERENCES sizes(id),
    FOREIGN KEY (driver_id) REFERENCES drivers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);

CREATE TRIGGER update_order_amount
BEFORE INSERT ON orders
FOR EACH ROW
    SET NEW.amount = (
        SELECT base_price
        FROM pizzas
        WHERE id = NEW.pizza_id
    ) * (
        SELECT price_ratio
        FROM sizes
        WHERE id = NEW.size_id
    );

-- Créé un trigger qui va changer la colonne orders.updated_at lorsque le statut d'une commande est modifiée
CREATE TRIGGER update_order_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW
    SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Créé un trigger qui vérifie le retard de livraison après une mise à jour de la table orders. Si le délai dépasse 30 min, la commande est gratuite et le compte du client est recrédité.
DELIMITER $$
CREATE TRIGGER update_order_amount_at_delay
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(MINUTE, OLD.updated_at, NEW.updated_at) > 30 THEN
        -- Mettre à jour le montant de la commande à 0
        SET NEW.amount = 0;
        
        -- Recréditer le compte du client
        UPDATE clients 
        SET balance = balance + (SELECT amount FROM orders WHERE id = NEW.id)
        WHERE id = (SELECT client_id FROM orders WHERE id = NEW.id);
    END IF;
END$$
DELIMITER ;



-- Routines
-- Obtenir les ingrédients composant une pizza
DELIMITER $$
CREATE PROCEDURE get_pizza_ingredients(IN pizza_id INT)
BEGIN
    SELECT i.id, i.name
    FROM ingredients i
    INNER JOIN pizza_ingredients pi ON pi.ingredient_id = i.id
    WHERE pi.pizza_id = pizza_id;
END $$
DELIMITER ;
-- Obtenir les pizzas triés par popularité en fonction du nombre d'occurence dans orders
DELIMITER $$
CREATE PROCEDURE get_pizzas_by_popularity()
BEGIN
    SELECT p.id , COUNT(*) AS popularite
    FROM pizzas p
    INNER JOIN orders o ON o.pizza_id = p.id
    WHERE o.status IN ('En cours', 'Validé')
    GROUP BY p.id
    ORDER BY popularite DESC;
END $$
DELIMITER ;

-- Obtenir les ingrédients triés par popularité en fonction du nombre d'occurence parmi les pizzas commandées dans orders
DELIMITER $$
CREATE PROCEDURE get_ingredients_by_popularity()
BEGIN
    SELECT i.id, i.name, COUNT(*) AS popularite
    FROM ingredients i
    INNER JOIN pizza_ingredients pi ON pi.ingredient_id = i.id
    INNER JOIN orders o ON o.pizza_id = pi.pizza_id
    WHERE o.status IN ('En cours', 'Validé')
    GROUP BY i.id
    ORDER BY popularite DESC;
END $$
DELIMITER ;

-- Obtenir les drivers triés par nombre de retard de livraison : on considère une livraison comme retardée si il y a plus de 30 minutes écoulées entre orders.created_at et orders.updated_at
DELIMITER $$
CREATE PROCEDURE get_drivers_by_delivery_delay()
BEGIN
    SELECT d.id, COUNT(*) AS delivery_delays
    FROM drivers d
    JOIN orders o ON o.driver_id = d.id
    WHERE TIMEDIFF(o.updated_at, o.created_at) > '00:30:00' AND o.status = 'Livré'
    GROUP BY d.id
    ORDER BY delivery_delays DESC;
END $$
DELIMITER ;


-- Calculer la moyenne des commandes
DELIMITER $$
CREATE PROCEDURE get_orders_average() 
BEGIN
    SELECT AVG(amount) FROM orders;
END $$
DELIMITER ;

-- Obtenir clients par ordre descendants de nombre de commandes
DELIMITER $$
CREATE PROCEDURE get_clients_by_total_orders() 
BEGIN
    SELECT client_id, COUNT(*) AS commandes_effectuees
    FROM orders
    WHERE status IN ('En cours', 'Validé')
    GROUP BY client_id
    ORDER BY commandes_effectuees DESC;
END $$
DELIMITER ;

-- Obtenir le nombre de commande par client
DELIMITER $$
CREATE PROCEDURE get_orders_count_by_client()
BEGIN
    SELECT client_id, COUNT(*) AS commandes_effectuees
    FROM orders
    WHERE status IN ('En cours', 'Validé')
    GROUP BY client_id;
END $$
DELIMITER ;

-- Obtenir le nombre de commande du client défini par client_id
DELIMITER $$
CREATE PROCEDURE get_orders_count_by_client_id(IN id INT)
BEGIN
    SELECT COUNT(*) AS commandes_effectuees
    FROM orders
    WHERE status IN ('En cours', 'Validé')
    AND client_id = id;
END $$
DELIMITER ;

-- Calculer le nombre de commandes effectuées en moyenne par les clients
DELIMITER $$
CREATE PROCEDURE get_average_orders_by_client()
BEGIN
    SELECT AVG(commandes_effectuees) AS commandes_moyennes
    FROM (
        SELECT client_id, COUNT(*) AS commandes_effectuees
        FROM orders
        WHERE status IN ('En cours', 'Validé')
        GROUP BY client_id
    ) AS commandes_par_client;
END $$
DELIMITER ;

-- Récupérer les clients ayant effectué plus de commandes que la moyenne
DELIMITER $$
CREATE PROCEDURE get_clients_with_more_orders_than_average()
BEGIN
    SELECT client_id, COUNT(*) AS commandes_effectuees
    FROM orders
    WHERE status IN ('En cours', 'Validé')
    GROUP BY client_id
    HAVING commandes_effectuees > (
        SELECT AVG(commandes_effectuees) AS commandes_moyennes
        FROM (
            SELECT client_id, COUNT(*) AS commandes_effectuees
            FROM orders
            WHERE status IN ('En cours', 'Validé')
            GROUP BY client_id
        ) AS commandes_par_client
    );
END $$
DELIMITER ;

-- Récupérer les véhicules n'ayant jamais servi
DELIMITER $$
CREATE PROCEDURE get_unused_vehicles()
BEGIN
    SELECT *
    FROM vehicles
    WHERE id NOT IN (
        SELECT vehicle_id
        FROM orders
        WHERE vehicle_id IS NOT NULL
    );
END $$
DELIMITER ;

-- Récupérer le chiffre d'affaire 
DELIMITER $$
CREATE PROCEDURE get_turnover()
BEGIN
    SELECT SUM(amount) as turnover
    FROM orders
    WHERE status IN ('En cours', 'Livré');
END $$
DELIMITER ;

-- Récupérer le retard éventuel d'une commande (si la différence entre orders.created_at et orders.updated_at > 30 minutes)
DELIMITER $$
CREATE PROCEDURE get_drivers_by_delivery_delay()
BEGIN
    SELECT d.id, COUNT(*) AS delivery_delays
    FROM drivers d
    JOIN orders o ON o.driver_id = d.id
    WHERE TIMEDIFF(o.updated_at, o.created_at) > '00:30:00' AND o.status = 'Livré'
    GROUP BY d.id
    ORDER BY delivery_delays DESC;
END $$
DELIMITER ;
-- Récupérer le retard éventuel d'une commande (si la différence entre orders.created_at et orders.updated_at > 30 minutes)
DELIMITER $$

CREATE PROCEDURE get_delay_from_order(IN order_id INT)
BEGIN
    DECLARE delay_duration TIME;
    
    SELECT TIMEDIFF(updated_at, created_at) INTO delay_duration
    FROM orders
    WHERE id = order_id
    ORDER BY created_at DESC
    LIMIT 1;
    
    SELECT IF(delay_duration > '00:30:00', delay_duration, NULL) AS delay;
END $$

DELIMITER ;