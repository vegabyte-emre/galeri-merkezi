-- Update brand logos
-- Generated on: 2026-01-26

-- First, clear existing catalog and recreate with logos
DELETE FROM vehicle_catalog_trims;
DELETE FROM vehicle_catalog_alt_models;
DELETE FROM vehicle_catalog_models;
DELETE FROM vehicle_catalog_series;
DELETE FROM vehicle_catalog_brands;
DELETE FROM vehicle_catalog_classes;

-- Reset sequences
ALTER SEQUENCE vehicle_catalog_classes_id_seq RESTART WITH 1;
ALTER SEQUENCE vehicle_catalog_brands_id_seq RESTART WITH 1;
ALTER SEQUENCE vehicle_catalog_series_id_seq RESTART WITH 1;
ALTER SEQUENCE vehicle_catalog_models_id_seq RESTART WITH 1;
ALTER SEQUENCE vehicle_catalog_alt_models_id_seq RESTART WITH 1;
ALTER SEQUENCE vehicle_catalog_trims_id_seq RESTART WITH 1;

-- Insert class
INSERT INTO vehicle_catalog_classes (name) VALUES ('Otomobil');

-- Insert all brands with logo URLs
INSERT INTO vehicle_catalog_brands (class_id, name, logo_url, is_popular, sort_order) VALUES
(1, 'Abarth', 'https://otobia.com/brands/Abarth.svg', false, 999),
(1, 'Aion', 'https://otobia.com/brands/Aion.svg', false, 999),
(1, 'Alfa Romeo', 'https://otobia.com/brands/Alfa%20Romeo.svg', false, 999),
(1, 'Alpine', 'https://otobia.com/brands/Alpine.svg', false, 999),
(1, 'Anadol', 'https://otobia.com/brands/Anadol.svg', false, 999),
(1, 'Arora', 'https://otobia.com/brands/Arora.svg', false, 999),
(1, 'Aston Martin', 'https://otobia.com/brands/Aston%20Martin.svg', false, 999),
(1, 'Audi', 'https://otobia.com/brands/Audi.svg', true, 10),
(1, 'Bentley', 'https://otobia.com/brands/Bentley.svg', false, 999),
(1, 'BMW', 'https://otobia.com/brands/BMW.svg', true, 5),
(1, 'Buick', 'https://otobia.com/brands/Buick.svg', false, 999),
(1, 'BYD', 'https://otobia.com/brands/BYD.svg', false, 999),
(1, 'Cadillac', 'https://otobia.com/brands/Cadillac.svg', false, 999),
(1, 'Chery', 'https://otobia.com/brands/Chery.svg', false, 999),
(1, 'Chevrolet', 'https://otobia.com/brands/Chevrolet.svg', false, 999),
(1, 'Chrysler', 'https://otobia.com/brands/Chrysler.svg', false, 999),
(1, 'Citroen', 'https://otobia.com/brands/C%C4%B1troen.svg', false, 999),
(1, 'Cupra', 'https://otobia.com/brands/Cupra.svg', false, 999),
(1, 'Dacia', 'https://otobia.com/brands/Dacia.svg', false, 999),
(1, 'Daewoo', 'https://otobia.com/brands/Daewoo.svg', false, 999),
(1, 'Daihatsu', 'https://otobia.com/brands/Daihatsu.svg', false, 999),
(1, 'Dodge', 'https://otobia.com/brands/Dodge.svg', false, 999),
(1, 'DS Automobiles', 'https://otobia.com/brands/DS%20Automobiles.svg', false, 999),
(1, 'Eagle', 'https://otobia.com/brands/Eagle.svg', false, 999),
(1, 'Ferrari', 'https://otobia.com/brands/Ferrari.svg', false, 999),
(1, 'Fiat', 'https://otobia.com/brands/Fiat.svg', true, 15),
(1, 'Ford', 'https://otobia.com/brands/Ford.svg', true, 8),
(1, 'Geely', 'https://otobia.com/brands/Geely.svg', false, 999),
(1, 'Honda', 'https://otobia.com/brands/Honda.svg', true, 12),
(1, 'Hyundai', 'https://otobia.com/brands/Hyundai.svg', true, 11),
(1, 'Ikco', 'https://otobia.com/brands/Ikco.svg', false, 999),
(1, 'Infiniti', 'https://otobia.com/brands/Infiniti.svg', false, 999),
(1, 'Jaguar', 'https://otobia.com/brands/Jaguar.svg', false, 999),
(1, 'Joyce', 'https://otobia.com/brands/Joyce.svg', false, 999),
(1, 'Kia', 'https://otobia.com/brands/Kia.svg', true, 13),
(1, 'Kuba', 'https://otobia.com/brands/Kuba%20Motor.svg', false, 999),
(1, 'Lada', 'https://otobia.com/brands/Lada.svg', false, 999),
(1, 'Lamborghini', 'https://otobia.com/brands/Lamborghini.svg', false, 999),
(1, 'Lancia', 'https://otobia.com/brands/Lancia.svg', false, 999),
(1, 'Leapmotor', 'https://otobia.com/brands/Leapmotor.svg', false, 999),
(1, 'Lexus', 'https://otobia.com/brands/Lexus.svg', false, 999),
(1, 'Lincoln', 'https://otobia.com/brands/Lincoln.svg', false, 999),
(1, 'Lotus', 'https://otobia.com/brands/Lotus.svg', false, 999),
(1, 'Marcos', 'https://otobia.com/brands/Marcos.svg', false, 999),
(1, 'Maserati', 'https://otobia.com/brands/Maserati.svg', false, 999),
(1, 'Mazda', 'https://otobia.com/brands/Mazda.svg', false, 999),
(1, 'McLaren', 'https://otobia.com/brands/Mc%20Laren.svg', false, 999),
(1, 'Mercedes-Benz', 'https://otobia.com/brands/Mercedes-Benz.svg', true, 3),
(1, 'MG', 'https://otobia.com/brands/MG.svg', false, 999),
(1, 'Micro', 'https://otobia.com/brands/Micro.svg', false, 999),
(1, 'Mini', 'https://otobia.com/brands/Mini.svg', false, 999),
(1, 'Mitsubishi', 'https://otobia.com/brands/Mitsubishi.svg', false, 999),
(1, 'Morgan', 'https://otobia.com/brands/Morgan.svg', false, 999),
(1, 'Nieve', 'https://otobia.com/brands/Nieve.svg', false, 999),
(1, 'Nissan', 'https://otobia.com/brands/Nissan.svg', true, 14),
(1, 'Opel', 'https://otobia.com/brands/Opel.svg', true, 16),
(1, 'Orti', 'https://otobia.com/brands/Orti.svg', false, 999),
(1, 'Peugeot', 'https://otobia.com/brands/Peugeot.svg', true, 9),
(1, 'Plymouth', 'https://otobia.com/brands/Plymouth.svg', false, 999),
(1, 'Polestar', 'https://otobia.com/brands/Polestar.svg', false, 999),
(1, 'Pontiac', 'https://otobia.com/brands/Pontiac.svg', false, 999),
(1, 'Porsche', 'https://otobia.com/brands/Porsche.svg', false, 999),
(1, 'Proton', 'https://otobia.com/brands/Proton.svg', false, 999),
(1, 'Rainwoll', 'https://otobia.com/brands/Rainwoll.svg', false, 999),
(1, 'Reeder', 'https://otobia.com/brands/Reeder.svg', false, 999),
(1, 'Regal Raptor', 'https://otobia.com/brands/Regal%20Raptor.svg', false, 999),
(1, 'Relive', 'https://otobia.com/brands/Relive.svg', false, 999),
(1, 'Renault', 'https://otobia.com/brands/Renault.svg', true, 6),
(1, 'RKS', 'https://otobia.com/brands/RKS.svg', false, 999),
(1, 'Rolls-Royce', 'https://otobia.com/brands/Rolls-Royce.svg', false, 999),
(1, 'Rover', 'https://otobia.com/brands/Rover.svg', false, 999),
(1, 'Saab', 'https://otobia.com/brands/Saab.svg', false, 999),
(1, 'Seat', 'https://otobia.com/brands/Seat.svg', false, 999),
(1, 'Skoda', 'https://otobia.com/brands/Skoda.svg', true, 17),
(1, 'Smart', 'https://otobia.com/brands/Smart.svg', false, 999),
(1, 'Subaru', 'https://otobia.com/brands/Subaru.svg', false, 999),
(1, 'Suzuki', 'https://otobia.com/brands/Suzuki.svg', false, 999),
(1, 'Tata', 'https://otobia.com/brands/Tata.svg', false, 999),
(1, 'Tesla', 'https://otobia.com/brands/Tesla.svg', false, 999),
(1, 'The London Taxi', 'https://otobia.com/brands/The%20London%20Taxi.svg', false, 999),
(1, 'Tofas', 'https://otobia.com/brands/Tofa%C5%9F.svg', false, 999),
(1, 'TOGG', 'https://otobia.com/brands/Togg.svg', true, 1),
(1, 'Toyota', 'https://otobia.com/brands/Toyota.svg', true, 7),
(1, 'Vanderhall', 'https://otobia.com/brands/Vanderhall.svg', false, 999),
(1, 'Volkswagen', 'https://otobia.com/brands/Volkswagen.svg', true, 4),
(1, 'Volta', 'https://otobia.com/brands/Volta.svg', false, 999),
(1, 'Volvo', 'https://otobia.com/brands/Volvo.svg', true, 18),
(1, 'XEV', 'https://otobia.com/brands/XEV.svg', false, 999),
(1, 'Yuki', 'https://otobia.com/brands/Yuki.svg', false, 999);
