-- Unified Database Schema for AOS Applications
-- This script creates the database structure that both applications can use

-- Create roles table first
CREATE TABLE IF NOT EXISTS role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Create utilisateur table
CREATE TABLE IF NOT EXISTS utilisateur (
    id SERIAL PRIMARY KEY,
    firstname VARCHAR(100) NOT NULL,
    lastname VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    matricule VARCHAR(50) UNIQUE,
    cin VARCHAR(50) UNIQUE,
    password VARCHAR(255) NOT NULL,
    account_locked BOOLEAN DEFAULT FALSE,
    enabled BOOLEAN DEFAULT TRUE,
    using_temporary_password BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create utilisateur_roles junction table
CREATE TABLE IF NOT EXISTS utilisateur_roles (
    utilisateur_id INTEGER REFERENCES utilisateur(id),
    role_id INTEGER REFERENCES role(id),
    PRIMARY KEY (utilisateur_id, role_id)
);

-- Create admin table
CREATE TABLE IF NOT EXISTS admin (
    id INTEGER PRIMARY KEY REFERENCES utilisateur(id)
);

-- Create support table
CREATE TABLE IF NOT EXISTS support (
    id INTEGER PRIMARY KEY REFERENCES utilisateur(id)
);

-- Create agent table
CREATE TABLE IF NOT EXISTS agent (
    id INTEGER PRIMARY KEY REFERENCES utilisateur(id)
);

-- Create service_info table
CREATE TABLE IF NOT EXISTS service_info (
    id SERIAL PRIMARY KEY,
    icon VARCHAR(100),
    title VARCHAR(255),
    description TEXT
);

-- Create service_features table
CREATE TABLE IF NOT EXISTS service_features (
    id SERIAL PRIMARY KEY,
    service_info_id INTEGER REFERENCES service_info(id),
    feature TEXT
);

-- Create service table
CREATE TABLE IF NOT EXISTS service (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    type VARCHAR(100),
    service_info_id INTEGER REFERENCES service_info(id),
    is_active BOOLEAN DEFAULT TRUE
);

-- Create specialized service tables
CREATE TABLE IF NOT EXISTS transport_service (
    id INTEGER PRIMARY KEY REFERENCES service(id),
    trajet VARCHAR(255),
    point_depart VARCHAR(255),
    point_arrivee VARCHAR(255),
    frequence VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS sante_sociale_service (
    id INTEGER PRIMARY KEY REFERENCES service(id),
    type_soin VARCHAR(255),
    montant DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS logement_service (
    id INTEGER PRIMARY KEY REFERENCES service(id),
    type_logement VARCHAR(255),
    localisation_souhaitee VARCHAR(255),
    montant_participation DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS colonie_vacance_service (
    id INTEGER PRIMARY KEY REFERENCES service(id),
    nombre_enfants INTEGER,
    lieu_souhaite VARCHAR(255),
    periode VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS appui_scolaire_service (
    id INTEGER PRIMARY KEY REFERENCES service(id),
    niveau VARCHAR(100),
    type_aide VARCHAR(255),
    montant_demande DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS activite_culturelle_sportive_service (
    id INTEGER PRIMARY KEY REFERENCES service(id),
    type_activite VARCHAR(255),
    nom_activite VARCHAR(255),
    date_activite VARCHAR(255)
);

-- Create demande table
CREATE TABLE IF NOT EXISTS demande (
    id SERIAL PRIMARY KEY,
    date_soumission TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statut VARCHAR(50),
    commentaire TEXT,
    document_reponse VARCHAR(500),
    utilisateur_id INTEGER NOT NULL REFERENCES utilisateur(id),
    service_id INTEGER NOT NULL REFERENCES service(id),
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create demande_documents table
CREATE TABLE IF NOT EXISTS demande_documents (
    demande_id INTEGER REFERENCES demande(id),
    document_path VARCHAR(500),
    PRIMARY KEY (demande_id, document_path)
);

-- Create reclamation table
CREATE TABLE IF NOT EXISTS reclamation (
    id SERIAL PRIMARY KEY,
    objet VARCHAR(255),
    contenu TEXT,
    statut VARCHAR(50),
    date_soumission TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    agent_id INTEGER REFERENCES agent(id),
    support_id INTEGER REFERENCES support(id),
    admin_id INTEGER REFERENCES admin(id),
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create message_contact table
CREATE TABLE IF NOT EXISTS message_contact (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255),
    email VARCHAR(255),
    sujet VARCHAR(255),
    contenu TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    handled_by_id INTEGER REFERENCES admin(id)
);

-- Create document_public table
CREATE TABLE IF NOT EXISTS document_public (
    id SERIAL PRIMARY KEY,
    titre VARCHAR(255),
    fichier_path VARCHAR(500),
    published_by_admin_id INTEGER REFERENCES admin(id),
    published_by_support_id INTEGER REFERENCES support(id),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create token table
CREATE TABLE IF NOT EXISTS token (
    id SERIAL PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    token_type VARCHAR(50),
    expired BOOLEAN DEFAULT FALSE,
    revoked BOOLEAN DEFAULT FALSE,
    utilisateur_id INTEGER REFERENCES utilisateur(id),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert initial roles
INSERT INTO role (id, name) VALUES 
(1, 'ADMIN'),
(2, 'SUPPORT'),
(3, 'AGENT')
ON CONFLICT (name) DO NOTHING;

-- Insert initial admin user (password: Temp123!)
INSERT INTO utilisateur (
    firstname, lastname, email, phone, matricule, cin, password, 
    account_locked, enabled, using_temporary_password
) VALUES 
('Admin', 'One', 'admin1@example.com', '1234567890', 'MAT001', 'CIN001', 
 '$2a$12$jvZ7NIosIS.eA5sX.KO3nO1z6JBQ082OECWKgmSVF23AGgIT3ihQS', 
 false, true, true)
ON CONFLICT (email) DO NOTHING;

-- Insert admin record
INSERT INTO admin (id)
SELECT id FROM utilisateur WHERE email = 'admin1@example.com'
ON CONFLICT (id) DO NOTHING;

-- Assign admin role
INSERT INTO utilisateur_roles (utilisateur_id, role_id)
SELECT u.id, r.id
FROM utilisateur u, role r
WHERE u.email = 'admin1@example.com' AND r.name = 'ADMIN'
ON CONFLICT (utilisateur_id, role_id) DO NOTHING;

-- Insert service info
INSERT INTO service_info (icon, title, description) VALUES 
('directions_bus', 'Service de Transport', 'Assistance pour les déplacements et frais de transport des employés'),
('local_hospital', 'Santé Sociale', 'Prise en charge des frais médicaux et de santé'),
('home', 'Logement', 'Aide au logement et participation aux frais d''habitation'),
('child_care', 'Colonies de Vacances', 'Organisation de colonies de vacances pour les enfants des employés'),
('school', 'Appui Scolaire', 'Soutien scolaire et aide aux frais d''éducation'),
('sports', 'Activités Culturelles et Sportives', 'Organisation d''activités culturelles et sportives')
ON CONFLICT DO NOTHING;

-- Insert services
INSERT INTO service (nom, type, service_info_id, is_active) VALUES 
('Transport Quotidien', 'TransportService', 1, TRUE),
('Assistance Médicale', 'SanteSocialeService', 2, TRUE),
('Aide au Logement', 'LogementService', 3, TRUE),
('Colonies de Vacances', 'ColonieVacanceService', 4, TRUE),
('Soutien Scolaire', 'AppuiScolaireService', 5, TRUE),
('Activités Loisirs', 'ActiviteCulturelleSportiveService', 6, TRUE)
ON CONFLICT DO NOTHING;
