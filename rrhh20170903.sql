--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cargo; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE cargo (
    id integer NOT NULL,
    nombre text NOT NULL,
    descripcion text
);


ALTER TABLE cargo OWNER TO personal;

--
-- Name: cargo_id_seq; Type: SEQUENCE; Schema: public; Owner: personal
--

CREATE SEQUENCE cargo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cargo_id_seq OWNER TO personal;

--
-- Name: cargo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: personal
--

ALTER SEQUENCE cargo_id_seq OWNED BY cargo.id;


--
-- Name: empleado; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE empleado (
    id integer NOT NULL,
    nombre text NOT NULL,
    apellido text NOT NULL,
    fecha_nacimiento date NOT NULL
);


ALTER TABLE empleado OWNER TO personal;

--
-- Name: historico_cargo; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE historico_cargo (
    id_emp integer,
    id_car integer,
    fecha_inicio date NOT NULL,
    fecha_final date
);


ALTER TABLE historico_cargo OWNER TO personal;

--
-- Name: cargo_vista; Type: VIEW; Schema: public; Owner: personal
--

CREATE VIEW cargo_vista AS
 SELECT e.id,
    e.nombre,
    e.apellido,
    c.nombre AS cargo
   FROM empleado e,
    cargo c,
    historico_cargo hc
  WHERE ((e.id = hc.id_emp) AND (c.id = hc.id_car) AND (hc.fecha_final IS NULL));


ALTER TABLE cargo_vista OWNER TO personal;

--
-- Name: empleado_id_seq; Type: SEQUENCE; Schema: public; Owner: personal
--

CREATE SEQUENCE empleado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE empleado_id_seq OWNER TO personal;

--
-- Name: empleado_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: personal
--

ALTER SEQUENCE empleado_id_seq OWNED BY empleado.id;


--
-- Name: entidad; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE entidad (
    id integer NOT NULL,
    descripcion character varying(50) NOT NULL
);


ALTER TABLE entidad OWNER TO personal;

--
-- Name: entidad_id_seq; Type: SEQUENCE; Schema: public; Owner: personal
--

CREATE SEQUENCE entidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE entidad_id_seq OWNER TO personal;

--
-- Name: entidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: personal
--

ALTER SEQUENCE entidad_id_seq OWNED BY entidad.id;


--
-- Name: extipo; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE extipo (
    id integer NOT NULL,
    id_ent integer NOT NULL,
    id_tip_ent integer NOT NULL
);


ALTER TABLE extipo OWNER TO personal;

--
-- Name: extipo_id_seq; Type: SEQUENCE; Schema: public; Owner: personal
--

CREATE SEQUENCE extipo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE extipo_id_seq OWNER TO personal;

--
-- Name: extipo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: personal
--

ALTER SEQUENCE extipo_id_seq OWNED BY extipo.id;


--
-- Name: historico_afiliaciones; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE historico_afiliaciones (
    id_emp integer NOT NULL,
    id_extipo integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_final date
);


ALTER TABLE historico_afiliaciones OWNER TO personal;

--
-- Name: historico_porcentaje; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE historico_porcentaje (
    id integer NOT NULL,
    id_tipo_ent integer,
    porcentaje_empleador numeric NOT NULL,
    porcentaje_empleado numeric NOT NULL,
    fecha date NOT NULL
);


ALTER TABLE historico_porcentaje OWNER TO personal;

--
-- Name: historico_porcentaje_id_seq; Type: SEQUENCE; Schema: public; Owner: personal
--

CREATE SEQUENCE historico_porcentaje_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE historico_porcentaje_id_seq OWNER TO personal;

--
-- Name: historico_porcentaje_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: personal
--

ALTER SEQUENCE historico_porcentaje_id_seq OWNED BY historico_porcentaje.id;


--
-- Name: salario; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE salario (
    id integer NOT NULL,
    id_car integer,
    fecha date NOT NULL,
    valor numeric NOT NULL
);


ALTER TABLE salario OWNER TO personal;

--
-- Name: salario_id_seq; Type: SEQUENCE; Schema: public; Owner: personal
--

CREATE SEQUENCE salario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE salario_id_seq OWNER TO personal;

--
-- Name: salario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: personal
--

ALTER SEQUENCE salario_id_seq OWNED BY salario.id;


--
-- Name: salario_vista; Type: VIEW; Schema: public; Owner: personal
--

CREATE VIEW salario_vista AS
 SELECT e.id,
    e.nombre,
    e.apellido,
    s.valor AS salario,
    s.fecha
   FROM empleado e,
    salario s,
    historico_cargo hc,
    ( SELECT c.id,
            max(s_1.fecha) AS fecha
           FROM cargo c,
            salario s_1
          WHERE (c.id = s_1.id_car)
          GROUP BY c.id) up
  WHERE ((e.id = hc.id_emp) AND (up.id = hc.id_car) AND (hc.fecha_final IS NULL) AND (up.id = s.id_car) AND (s.fecha = up.fecha));


ALTER TABLE salario_vista OWNER TO personal;

--
-- Name: salario_total_vista; Type: VIEW; Schema: public; Owner: personal
--

CREATE VIEW salario_total_vista AS
 SELECT ec.cargo,
    sum(es.salario) AS total_pago
   FROM cargo_vista ec,
    salario_vista es
  WHERE (ec.id = es.id)
  GROUP BY ec.cargo;


ALTER TABLE salario_total_vista OWNER TO personal;

--
-- Name: tipo_entidad; Type: TABLE; Schema: public; Owner: personal
--

CREATE TABLE tipo_entidad (
    id integer NOT NULL,
    descripcion character varying(50) NOT NULL
);


ALTER TABLE tipo_entidad OWNER TO personal;

--
-- Name: tipo_entidad_id_seq; Type: SEQUENCE; Schema: public; Owner: personal
--

CREATE SEQUENCE tipo_entidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipo_entidad_id_seq OWNER TO personal;

--
-- Name: tipo_entidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: personal
--

ALTER SEQUENCE tipo_entidad_id_seq OWNED BY tipo_entidad.id;


--
-- Name: cargo id; Type: DEFAULT; Schema: public; Owner: personal
--

ALTER TABLE ONLY cargo ALTER COLUMN id SET DEFAULT nextval('cargo_id_seq'::regclass);


--
-- Name: empleado id; Type: DEFAULT; Schema: public; Owner: personal
--

ALTER TABLE ONLY empleado ALTER COLUMN id SET DEFAULT nextval('empleado_id_seq'::regclass);


--
-- Name: entidad id; Type: DEFAULT; Schema: public; Owner: personal
--

ALTER TABLE ONLY entidad ALTER COLUMN id SET DEFAULT nextval('entidad_id_seq'::regclass);


--
-- Name: extipo id; Type: DEFAULT; Schema: public; Owner: personal
--

ALTER TABLE ONLY extipo ALTER COLUMN id SET DEFAULT nextval('extipo_id_seq'::regclass);


--
-- Name: historico_porcentaje id; Type: DEFAULT; Schema: public; Owner: personal
--

ALTER TABLE ONLY historico_porcentaje ALTER COLUMN id SET DEFAULT nextval('historico_porcentaje_id_seq'::regclass);


--
-- Name: salario id; Type: DEFAULT; Schema: public; Owner: personal
--

ALTER TABLE ONLY salario ALTER COLUMN id SET DEFAULT nextval('salario_id_seq'::regclass);


--
-- Name: tipo_entidad id; Type: DEFAULT; Schema: public; Owner: personal
--

ALTER TABLE ONLY tipo_entidad ALTER COLUMN id SET DEFAULT nextval('tipo_entidad_id_seq'::regclass);


--
-- Data for Name: cargo; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY cargo (id, nombre, descripcion) FROM stdin;
1	gerente	manda
2	subgerente	
3	supervisor	controla
4	vendedor	vende
5	operario	hace caso
\.


--
-- Name: cargo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: personal
--

SELECT pg_catalog.setval('cargo_id_seq', 5, true);


--
-- Data for Name: empleado; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY empleado (id, nombre, apellido, fecha_nacimiento) FROM stdin;
1	AAA	aaa	1975-06-15
2	BBB	bbb	1989-07-07
3	CCC	ccc	1990-05-04
4	DDD	ddd	1980-02-01
5	EEE	EEE	1983-01-01
6	prueba	prueba_ap	1993-12-06
7	FFF	fff	2017-03-07
8	GGG	ggg	2017-03-07
\.


--
-- Name: empleado_id_seq; Type: SEQUENCE SET; Schema: public; Owner: personal
--

SELECT pg_catalog.setval('empleado_id_seq', 8, true);


--
-- Data for Name: entidad; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY entidad (id, descripcion) FROM stdin;
1	Sanitas
2	Colpensiones
3	Porvenir
4	Cafesalud
5	Colfondos S.A
\.


--
-- Name: entidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: personal
--

SELECT pg_catalog.setval('entidad_id_seq', 5, true);


--
-- Data for Name: extipo; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY extipo (id, id_ent, id_tip_ent) FROM stdin;
1	1	1
2	2	2
3	3	2
4	4	1
5	5	2
\.


--
-- Name: extipo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: personal
--

SELECT pg_catalog.setval('extipo_id_seq', 5, true);


--
-- Data for Name: historico_afiliaciones; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY historico_afiliaciones (id_emp, id_extipo, fecha_inicio, fecha_final) FROM stdin;
1	1	2015-01-01	2015-12-31
2	1	2015-01-01	2015-12-31
1	1	2016-01-01	2016-06-30
1	2	2015-01-01	2015-12-31
2	2	2015-01-01	2015-12-31
1	2	2016-01-01	2016-06-30
3	4	2015-01-01	\N
3	5	2015-01-01	\N
4	1	2015-01-01	\N
4	3	2015-01-01	\N
6	4	2015-01-01	\N
6	3	2015-01-01	\N
7	3	2016-08-01	\N
8	4	2016-08-01	\N
8	5	2016-08-01	\N
7	1	2016-08-01	\N
\.


--
-- Data for Name: historico_cargo; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY historico_cargo (id_emp, id_car, fecha_inicio, fecha_final) FROM stdin;
1	2	2015-01-01	2015-12-31
2	1	2015-01-01	2015-12-31
3	3	2015-01-01	\N
4	4	2015-01-01	\N
5	5	2015-01-01	\N
1	1	2016-01-01	2016-06-30
6	5	2015-01-01	\N
7	1	2016-08-01	\N
8	2	2016-08-01	\N
\.


--
-- Data for Name: historico_porcentaje; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY historico_porcentaje (id, id_tipo_ent, porcentaje_empleador, porcentaje_empleado, fecha) FROM stdin;
1	1	8.5	4	2017-01-01
2	2	12	4	2017-01-01
\.


--
-- Name: historico_porcentaje_id_seq; Type: SEQUENCE SET; Schema: public; Owner: personal
--

SELECT pg_catalog.setval('historico_porcentaje_id_seq', 2, true);


--
-- Data for Name: salario; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY salario (id, id_car, fecha, valor) FROM stdin;
1	1	2015-01-01	5000000
2	2	2015-01-01	3000000
3	3	2015-01-01	1500000
4	4	2015-01-01	1500000
5	5	2015-01-01	8000000
6	1	2016-01-01	5500000
7	2	2016-01-01	3300000
8	3	2016-01-01	1650000
9	4	2016-01-01	1050000
10	5	2016-01-01	850000
12	1	2017-01-01	5940000
13	2	2017-01-01	3564000
14	3	2017-01-01	1782000
15	4	2017-01-01	1134000
16	5	2017-01-01	918000
17	1	2017-01-01	6415200
18	2	2017-01-01	3849120
19	3	2017-01-01	1924560
20	4	2017-01-01	1224720
21	5	2017-01-01	991440
\.


--
-- Name: salario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: personal
--

SELECT pg_catalog.setval('salario_id_seq', 21, true);


--
-- Data for Name: tipo_entidad; Type: TABLE DATA; Schema: public; Owner: personal
--

COPY tipo_entidad (id, descripcion) FROM stdin;
1	Salud
2	Pensiones
\.


--
-- Name: tipo_entidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: personal
--

SELECT pg_catalog.setval('tipo_entidad_id_seq', 2, true);


--
-- Name: cargo cargo_pkey; Type: CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY cargo
    ADD CONSTRAINT cargo_pkey PRIMARY KEY (id);


--
-- Name: empleado empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id);


--
-- Name: entidad entidad_pkey; Type: CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT entidad_pkey PRIMARY KEY (id);


--
-- Name: extipo extipo_pkey; Type: CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY extipo
    ADD CONSTRAINT extipo_pkey PRIMARY KEY (id);


--
-- Name: historico_porcentaje historico_porcentaje_pkey; Type: CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY historico_porcentaje
    ADD CONSTRAINT historico_porcentaje_pkey PRIMARY KEY (id);


--
-- Name: salario salario_pkey; Type: CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY salario
    ADD CONSTRAINT salario_pkey PRIMARY KEY (id);


--
-- Name: tipo_entidad tipo_entidad_pkey; Type: CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY tipo_entidad
    ADD CONSTRAINT tipo_entidad_pkey PRIMARY KEY (id);


--
-- Name: extipo extipo_id_ent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY extipo
    ADD CONSTRAINT extipo_id_ent_fkey FOREIGN KEY (id_ent) REFERENCES entidad(id);


--
-- Name: extipo extipo_id_tip_ent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY extipo
    ADD CONSTRAINT extipo_id_tip_ent_fkey FOREIGN KEY (id_tip_ent) REFERENCES tipo_entidad(id);


--
-- Name: historico_afiliaciones historico_afiliaciones_id_emp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY historico_afiliaciones
    ADD CONSTRAINT historico_afiliaciones_id_emp_fkey FOREIGN KEY (id_emp) REFERENCES empleado(id);


--
-- Name: historico_afiliaciones historico_afiliaciones_id_extipo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY historico_afiliaciones
    ADD CONSTRAINT historico_afiliaciones_id_extipo_fkey FOREIGN KEY (id_extipo) REFERENCES extipo(id);


--
-- Name: historico_porcentaje historico_porcentaje_id_tipo_ent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY historico_porcentaje
    ADD CONSTRAINT historico_porcentaje_id_tipo_ent_fkey FOREIGN KEY (id_tipo_ent) REFERENCES tipo_entidad(id);


--
-- Name: historico_cargo historico_table_id_car_fkey; Type: FK CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY historico_cargo
    ADD CONSTRAINT historico_table_id_car_fkey FOREIGN KEY (id_car) REFERENCES cargo(id);


--
-- Name: historico_cargo historico_table_id_emp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY historico_cargo
    ADD CONSTRAINT historico_table_id_emp_fkey FOREIGN KEY (id_emp) REFERENCES empleado(id);


--
-- Name: salario salario_id_car_fkey; Type: FK CONSTRAINT; Schema: public; Owner: personal
--

ALTER TABLE ONLY salario
    ADD CONSTRAINT salario_id_car_fkey FOREIGN KEY (id_car) REFERENCES cargo(id);


--
-- Name: cargo; Type: ACL; Schema: public; Owner: personal
--

GRANT SELECT ON TABLE cargo TO consulta_nomina;
GRANT SELECT ON TABLE cargo TO contratacion;


--
-- Name: empleado; Type: ACL; Schema: public; Owner: personal
--

GRANT SELECT ON TABLE empleado TO consulta_nomina;
GRANT SELECT,INSERT ON TABLE empleado TO contratacion;


--
-- Name: historico_cargo; Type: ACL; Schema: public; Owner: personal
--

GRANT SELECT ON TABLE historico_cargo TO consulta_nomina;
GRANT SELECT,INSERT ON TABLE historico_cargo TO contratacion;


--
-- Name: cargo_vista; Type: ACL; Schema: public; Owner: personal
--

GRANT SELECT ON TABLE cargo_vista TO consulta_nomina;
GRANT SELECT ON TABLE cargo_vista TO contratacion;


--
-- Name: empleado_id_seq; Type: ACL; Schema: public; Owner: personal
--

GRANT ALL ON SEQUENCE empleado_id_seq TO contratacion;


--
-- Name: salario; Type: ACL; Schema: public; Owner: personal
--

GRANT SELECT ON TABLE salario TO consulta_nomina;
GRANT SELECT,INSERT ON TABLE salario TO contratacion;


--
-- Name: salario_id_seq; Type: ACL; Schema: public; Owner: personal
--

GRANT ALL ON SEQUENCE salario_id_seq TO contratacion;


--
-- Name: salario_vista; Type: ACL; Schema: public; Owner: personal
--

GRANT SELECT ON TABLE salario_vista TO consulta_nomina;
GRANT SELECT ON TABLE salario_vista TO contratacion;


--
-- Name: salario_total_vista; Type: ACL; Schema: public; Owner: personal
--

GRANT SELECT ON TABLE salario_total_vista TO consulta_nomina;
GRANT SELECT ON TABLE salario_total_vista TO contratacion;


--
-- PostgreSQL database dump complete
--

