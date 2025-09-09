

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
ON CONFLICT (title) DO NOTHING;

-- Insert services
INSERT INTO service (nom, type, service_info_id, is_active) VALUES 
('Transport Quotidien', 'TransportService', 1, TRUE),
('Assistance Médicale', 'SanteSocialeService', 2, TRUE),
('Aide au Logement', 'LogementService', 3, TRUE),
('Colonies de Vacances', 'ColonieVacanceService', 4, TRUE),
('Soutien Scolaire', 'AppuiScolaireService', 5, TRUE),
('Activités Loisirs', 'ActiviteCulturelleSportiveService', 6, TRUE)
ON CONFLICT DO NOTHING;
