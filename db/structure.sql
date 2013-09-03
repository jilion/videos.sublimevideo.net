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


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


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
    url text NOT NULL,
    quality character varying(255),
    family character varying(255),
    resolution character varying(255),
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    issues character varying(255)[] DEFAULT '{}'::character varying[]
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
    site_token character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    uid_origin character varying(255) DEFAULT 'attribute'::character varying NOT NULL,
    title character varying(255),
    title_origin character varying(255),
    sources_id character varying(255),
    sources_origin character varying(255),
    poster_url text,
    size character varying(255),
    duration integer,
    settings hstore,
    options hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    player_stage character varying(255) DEFAULT 'stable'::character varying,
    starts integer[] DEFAULT '{}'::integer[],
    last_30_days_starts integer,
    last_90_days_starts integer,
    last_365_days_starts integer,
    loaded_at timestamp without time zone,
    starts_updated_at timestamp without time zone
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

ALTER TABLE ONLY video_sources ALTER COLUMN id SET DEFAULT nextval('video_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY video_tags ALTER COLUMN id SET DEFAULT nextval('video_tags_id_seq'::regclass);


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
-- Name: index_video_tags_on_loaded_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_video_tags_on_loaded_at ON video_tags USING btree (loaded_at);


--
-- Name: index_video_tags_on_site_token_and_last_30_days_starts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_video_tags_on_site_token_and_last_30_days_starts ON video_tags USING btree (site_token, last_30_days_starts);


--
-- Name: index_video_tags_on_site_token_and_last_365_days_starts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_video_tags_on_site_token_and_last_365_days_starts ON video_tags USING btree (site_token, last_365_days_starts);


--
-- Name: index_video_tags_on_site_token_and_last_90_days_starts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_video_tags_on_site_token_and_last_90_days_starts ON video_tags USING btree (site_token, last_90_days_starts);


--
-- Name: index_video_tags_on_site_token_and_loaded_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_video_tags_on_site_token_and_loaded_at ON video_tags USING btree (site_token, loaded_at);


--
-- Name: index_video_tags_on_site_token_and_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_video_tags_on_site_token_and_uid ON video_tags USING btree (site_token, uid);


--
-- Name: index_video_tags_on_starts_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_video_tags_on_starts_updated_at ON video_tags USING btree (starts_updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: video_tags_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX video_tags_to_tsvector_idx ON video_tags USING gin (to_tsvector('english'::regconfig, (title)::text));


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130206143949');

INSERT INTO schema_migrations (version) VALUES ('20130206143950');

INSERT INTO schema_migrations (version) VALUES ('20130308091208');

INSERT INTO schema_migrations (version) VALUES ('20130415085658');

INSERT INTO schema_migrations (version) VALUES ('20130617092307');

INSERT INTO schema_migrations (version) VALUES ('20130903143855');
