-- Utilisation de la BDD "3i_in10"
use 3i_in10;

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
    id INT AUTO_INCREMENT,
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
    total_orders INT DEFAULT 0 -- On met le nombre de commande par défaut à 0
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

