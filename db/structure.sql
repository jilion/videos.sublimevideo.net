--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: video_sources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE video_sources (
    id integer NOT NULL,
    video_tag_id integer NOT NULL,
    url character varying(255) NOT NULL,
    quality character varying(255) NOT NULL,
    family character varying(255) NOT NULL,
    resolution character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: video_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE video_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: video_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE video_sources_id_seq OWNED BY video_sources.id;


--
-- Name: video_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE video_tags (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    uid_origin character varying(255) DEFAULT 'attribute'::character varying NOT NULL,
    name character varying(255),
    name_origin character varying(255),
    sources_id character varying(255),
    sources_origin character varying(255),
    poster_url text,
    size character varying(255),
    duration integer,
    sources text,
    settings hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_token character varying(255) NOT NULL
);


--
-- Name: video_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE video_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: video_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE video_tags_id_seq OWNED BY video_tags.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE video_sources ALTER COLUMN id SET DEFAULT nextval('video_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE video_tags ALTER COLUMN id SET DEFAULT nextval('video_tags_id_seq'::regclass);


--
-- Name: video_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY video_sources
    ADD CONSTRAINT video_sources_pkey PRIMARY KEY (id);


--
-- Name: video_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY video_tags
    ADD CONSTRAINT video_tags_pkey PRIMARY KEY (id);


--
-- Name: index_video_sources_on_video_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_video_sources_on_video_tag_id ON video_sources USING btree (video_tag_id);


--
-- Name: index_video_tags_on_site_token_and_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_video_tags_on_site_token_and_uid ON video_tags USING btree (site_token, uid);


--
-- Name: index_video_tags_on_site_token_and_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_video_tags_on_site_token_and_updated_at ON video_tags USING btree (site_token, updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20121115083239');

INSERT INTO schema_migrations (version) VALUES ('20121122073822');

INSERT INTO schema_migrations (version) VALUES ('20130129102056');

INSERT INTO schema_migrations (version) VALUES ('20130129130402');

INSERT INTO schema_migrations (version) VALUES ('20130129143831');
