colocar códigos e etc(sql)

CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    crm VARCHAR(20) NOT NULL UNIQUE,
    valor_consulta NUMERIC(10, 2) NOT NULL CHECK (valor_consulta > 0),
    CONSTRAINT fk_medico_especialidade 
        FOREIGN KEY (especialidade_id) 
        REFERENCES especialidades(id)
);


CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL,
    paciente_id INT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Realizada', 'Cancelada')),
    CONSTRAINT fk_consulta_medico 
        FOREIGN KEY (medico_id) 
        REFERENCES medicos(id),
    CONSTRAINT fk_consulta_paciente 
        FOREIGN KEY (paciente_id) 
        REFERENCES pacientes(id)
);


CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL,
    nome_exame VARCHAR(150) NOT NULL,
    valor_exame NUMERIC(10, 2) NOT NULL CHECK (valor_exame >= 0),
    CONSTRAINT fk_exame_consulta 
        FOREIGN KEY (consulta_id) 
        REFERENCES consultas(id)
);

INSERT INTO especialidades (nome) VALUES 
('Cardiologia'),
('Pediatria'),
('Dermatologia');


INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES 
('Carlos Silva', 'carlos.silva@email.com', '12345678901', '1985-05-15'),
('Ana Oliveira', 'ana.oliveira@email.com', '98765432100', '1992-10-20'),
('Mariana Santos', 'mariana.santos@email.com', '45678912305', '1978-03-08');


INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES 
(1, 'Dr. Roberto Costa', 'CRM/SP 111111', 350.00),
(2, 'Dra. Patricia Lima', 'CRM/SP 222222', 250.00),
(3, 'Dr. Fernando Souza', 'CRM/SP 333333', 400.00);

INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES 
(1, 1, '2026-03-10 14:00:00', 'Realizada'), 
(2, 1, '2026-03-15 10:30:00', 'Agendada'), 
(3, 2, '2026-03-11 09:00:00', 'Realizada'),
(1, 3, '2026-03-12 16:00:00', 'Cancelada');

INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES 
(1, 'Eletrocardiograma', 120.00),
(1, 'Ecocardiograma', 250.00),
(3, 'Hemograma Completo', 45.00),
(3, 'Perfil Lipídico', 60.00);

SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
JOIN especialidades e ON m.especialidade_id = e.id
ORDER BY m.valor_consulta DESC;

SELECT 
    c.id AS consulta_id,
    c.data_hora,
    m.nome AS medico,
    e.nome AS especialidade,
    c.status
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
WHERE p.nome = 'Carlos Silva';

SELECT 
    c.id AS consulta_id,
    p.nome AS paciente,
    m.nome AS medico,
    (m.valor_consulta + COALESCE(SUM(ex.valor_exame), 0)) AS valor_total_calculado
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
LEFT JOIN exames_consulta ex ON ex.consulta_id = c.id
GROUP BY c.id, p.nome, m.nome, m.valor_consulta;

SELECT 
    nome,
    crm,
    valor_consulta
FROM medicos
WHERE valor_consulta > 300.00;

SELECT 
    e.nome AS especialidade,
    SUM(m.valor_consulta) AS total_faturado
FROM consultas c
JOIN medicos m ON c.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
WHERE c.status = 'Realizada'
GROUP BY e.nome;
