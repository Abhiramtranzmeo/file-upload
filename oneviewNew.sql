--
-- PostgreSQL database dump
--

-- Dumped from database version 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: create_partition_and_insert(); Type: FUNCTION; Schema: public; Owner: safil
--

CREATE FUNCTION public.create_partition_and_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    partition TEXT;
    "partition_day" TEXT;
    BEGIN
        "partition_day":=extract(day from NEW.datetime)::text;
        partition := TG_RELNAME || '_' || "partition_day";
        IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=partition) THEN
            RAISE NOTICE 'A partition has been created %',partition;
            EXECUTE 'CREATE TABLE ' || partition || '(check ((extract(month from datetime))= ' || "partition_day"||')) INHERITS (' || TG_RELNAME || ');';
            EXECUTE format($$ALTER TABLE ONLY %I ADD PRIMARY KEY (id)$$, partition);
        END IF;
        EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').* RETURNING id;';
        RETURN NULL;
        END;
    $_$;


ALTER FUNCTION public.create_partition_and_insert() OWNER TO safil;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acknowledgement; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.acknowledgement (
    id integer NOT NULL,
    "pidsinfoId" integer NOT NULL,
    "channelId" integer NOT NULL,
    alarmid integer NOT NULL,
    remarks text,
    imageurl character(1000),
    predictedevent text,
    actualevent text,
    "userId" integer,
    "isSynced" boolean,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);


ALTER TABLE public.acknowledgement OWNER TO safil;

--
-- Name: acknowledgement_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.acknowledgement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acknowledgement_id_seq OWNER TO safil;

--
-- Name: acknowledgement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.acknowledgement_id_seq OWNED BY public.acknowledgement.id;


--
-- Name: channelinfo; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.channelinfo (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    binsize double precision,
    startpos double precision,
    amplitudenumber double precision,
    "pidsinfoId" integer,
    "channelId" integer,
    isconfigchanged boolean DEFAULT false,
    profile jsonb,
    comments text,
    "isSynced" boolean,
    "createdAt" time without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" time without time zone DEFAULT CURRENT_TIMESTAMP,
    "regioninfoId" integer NOT NULL
);


ALTER TABLE public.channelinfo OWNER TO safil;

--
-- Name: channelinfo_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.channelinfo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.channelinfo_id_seq OWNER TO safil;

--
-- Name: channelinfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.channelinfo_id_seq OWNED BY public.channelinfo.id;


--
-- Name: dashboard; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.dashboard (
    id integer NOT NULL,
    date date NOT NULL,
    "regeoninfoId" integer NOT NULL,
    alarmdetails jsonb,
    totalevents jsonb,
    inspectioncount integer,
    resolutiondetails jsonb,
    acknowledgementcount integer
);


ALTER TABLE public.dashboard OWNER TO safil;

--
-- Name: dashboard_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.dashboard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dashboard_id_seq OWNER TO safil;

--
-- Name: dashboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.dashboard_id_seq OWNED BY public.dashboard.id;


--
-- Name: fibreshotmonitoring; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.fibreshotmonitoring (
    id integer NOT NULL,
    date date NOT NULL,
    "pidsinfoId" integer NOT NULL,
    fibercount jsonb,
    hourly jsonb,
    daily double precision,
    switchingloss jsonb,
    hourlyswitchingloss jsonb,
    dailyswitchingloss double precision,
    "isSynced" boolean
);


ALTER TABLE public.fibreshotmonitoring OWNER TO safil;

--
-- Name: fibreshotmonitoring_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.fibreshotmonitoring_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fibreshotmonitoring_id_seq OWNER TO safil;

--
-- Name: fibreshotmonitoring_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.fibreshotmonitoring_id_seq OWNED BY public.fibreshotmonitoring.id;


--
-- Name: pidsconfiglog; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.pidsconfiglog (
    id integer NOT NULL,
    "pidsinfoId" integer NOT NULL,
    datetime timestamp without time zone NOT NULL,
    log jsonb
);


ALTER TABLE public.pidsconfiglog OWNER TO safil;

--
-- Name: pidsconfiglog_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.pidsconfiglog_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pidsconfiglog_id_seq OWNER TO safil;

--
-- Name: pidsconfiglog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.pidsconfiglog_id_seq OWNED BY public.pidsconfiglog.id;


--
-- Name: pidsinfo; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.pidsinfo (
    id integer NOT NULL,
    name character varying(100),
    ipaddress text,
    latitude double precision,
    longitude double precision,
    productionstatus character varying(10) DEFAULT 'E'::character varying,
    onproduction boolean DEFAULT false,
    "channelId" integer[],
    "createdAt" time without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" time without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.pidsinfo OWNER TO safil;

--
-- Name: pidsinfo_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.pidsinfo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pidsinfo_id_seq OWNER TO safil;

--
-- Name: pidsinfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.pidsinfo_id_seq OWNED BY public.pidsinfo.id;


--
-- Name: pidsstatus; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.pidsstatus (
    date date NOT NULL,
    "pidsinfoId" integer NOT NULL,
    pidslog jsonb,
    status boolean,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "isSynced" boolean,
    id integer NOT NULL
);


ALTER TABLE public.pidsstatus OWNER TO safil;

--
-- Name: pidsstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.pidsstatus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pidsstatus_id_seq OWNER TO safil;

--
-- Name: pidsstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.pidsstatus_id_seq OWNED BY public.pidsstatus.id;


--
-- Name: pigtracking; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.pigtracking (
    id integer NOT NULL,
    "channelId" integer,
    mid_position double precision,
    pig_width double precision,
    ispigenabled boolean
);


ALTER TABLE public.pigtracking OWNER TO safil;

--
-- Name: pigtracking_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.pigtracking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pigtracking_id_seq OWNER TO safil;

--
-- Name: pigtracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.pigtracking_id_seq OWNED BY public.pigtracking.id;


--
-- Name: pipelineconfig; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.pipelineconfig (
    id integer NOT NULL,
    "PipelineChainage" double precision NOT NULL,
    "ROUMarker" text NOT NULL,
    "ODMeter" double precision NOT NULL,
    "Latitude" double precision NOT NULL,
    "Longitude" double precision NOT NULL,
    "regioninfoId" integer NOT NULL,
    "channelId" integer NOT NULL,
    "pidsinfoId" integer NOT NULL,
    "TerrainClassification" text NOT NULL,
    "LandmarkDescription" text NOT NULL,
    "AddionalDecription" text,
    "VulnerablePoint" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.pipelineconfig OWNER TO safil;

--
-- Name: pipelineconfig_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.pipelineconfig_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pipelineconfig_id_seq OWNER TO safil;

--
-- Name: pipelineconfig_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.pipelineconfig_id_seq OWNED BY public.pipelineconfig.id;


--
-- Name: ramanmandialarm; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.ramanmandialarm (
    id integer NOT NULL,
    eventid integer NOT NULL,
    alarmseverity integer NOT NULL,
    "ruleinfoId" integer NOT NULL,
    relatedalarm integer[],
    datetime timestamp without time zone,
    continuityprocessed boolean,
    status boolean,
    isparent boolean,
    ackdetails jsonb,
    resolutiondetails jsonb,
    distinctevents text[],
    duration double precision,
    inspectionsid integer,
    groupedalarms integer[],
    "isSynced" boolean,
    resolutionsynced boolean,
    "pipelineconfigId" integer,
    "pipelinemeters" integer
);


ALTER TABLE public.ramanmandialarm OWNER TO safil;

--
-- Name: ramanmandialarm_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.ramanmandialarm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ramanmandialarm_id_seq OWNER TO safil;

--
-- Name: ramanmandialarm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.ramanmandialarm_id_seq OWNED BY public.ramanmandialarm.id;


--
-- Name: ramanmandieventconfirmed; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.ramanmandieventconfirmed (
    id integer NOT NULL,
    eventdate date,
    eventtime time without time zone,
    eventchannel integer,
    eventtype character varying(50),
    eventamplitude double precision,
    eventwidth double precision,
    isparent boolean,
    eventconfidence double precision,
    relatedevents integer[],
    alarmprocessed boolean DEFAULT false,
    continuityprocessed boolean DEFAULT false,
    datetime timestamp without time zone,
    starttime time without time zone,
    endtime time without time zone,
    duration double precision,
    "pipelineconfigId" integer
);


ALTER TABLE public.ramanmandieventconfirmed OWNER TO safil;

--
-- Name: ramanmandieventconfirmed_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.ramanmandieventconfirmed_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ramanmandieventconfirmed_id_seq OWNER TO safil;

--
-- Name: ramanmandieventconfirmed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.ramanmandieventconfirmed_id_seq OWNED BY public.ramanmandieventconfirmed.id;


--
-- Name: ramanmandifibreshot; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.ramanmandifibreshot (
    id integer NOT NULL,
    "channelId" integer NOT NULL,
    fibreshottime timestamp with time zone NOT NULL,
    fibreshotcreatedtime timestamp with time zone NOT NULL,
    amplitudes double precision NOT NULL,
    isprocessed boolean NOT NULL,
    binsize double precision NOT NULL,
    numamplitudes double precision NOT NULL,
    startposition double precision NOT NULL,
    counted boolean NOT NULL
);


ALTER TABLE public.ramanmandifibreshot OWNER TO safil;

--
-- Name: ramanmandifibreshot_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.ramanmandifibreshot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ramanmandifibreshot_id_seq OWNER TO safil;

--
-- Name: ramanmandifibreshot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.ramanmandifibreshot_id_seq OWNED BY public.ramanmandifibreshot.id;


--
-- Name: ramanmandiramanmandipredictedevents; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.ramanmandiramanmandipredictedevents (
    id integer NOT NULL,
    eventchannel integer,
    eventtype character varying(50),
    eventamplitude double precision,
    starttime time without time zone,
    endtime time without time zone,
    isconfirmed boolean,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone NOT NULL,
    "pipelineconfigId" integer NOT NULL,
    datetime timestamp without time zone,
    eventconfidence double precision
);


ALTER TABLE public.ramanmandiramanmandipredictedevents OWNER TO safil;

--
-- Name: ramanmandipredictedevents_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.ramanmandipredictedevents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ramanmandipredictedevents_id_seq OWNER TO safil;

--
-- Name: ramanmandipredictedevents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.ramanmandipredictedevents_id_seq OWNED BY public.ramanmandiramanmandipredictedevents.id;


--
-- Name: ramanmandipredictedevents_isconfirmed_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.ramanmandipredictedevents_isconfirmed_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ramanmandipredictedevents_isconfirmed_seq OWNER TO safil;

--
-- Name: ramanmandipredictedevents_isconfirmed_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.ramanmandipredictedevents_isconfirmed_seq OWNED BY public.ramanmandiramanmandipredictedevents.isconfirmed;


--
-- Name: regioninfo; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.regioninfo (
    id integer NOT NULL,
    regionname text NOT NULL,
    locationname text NOT NULL,
    "StartChainage" double precision NOT NULL,
    "EndChainage" double precision NOT NULL,
    "StartLatitude" double precision NOT NULL,
    "EndLatitude" double precision NOT NULL,
    "ROUName" text NOT NULL,
    "ROUMobileNumber" text NOT NULL,
    "PipelineGroup" text,
    "PipelineSection" text,
    "TypeofPipeline" text
);


ALTER TABLE public.regioninfo OWNER TO safil;

--
-- Name: regioninfo_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.regioninfo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.regioninfo_id_seq OWNER TO safil;

--
-- Name: regioninfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.regioninfo_id_seq OWNED BY public.regioninfo.id;


--
-- Name: resolution; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.resolution (
    id integer NOT NULL,
    predictedevent text,
    actualevent text,
    remarks text,
    isenabledforretraining boolean,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    alarmid integer,
    imageurl character(1000)[],
    "userId" integer,
    "isSynced" boolean,
    "pidsinfoId" integer
);


ALTER TABLE public.resolution OWNER TO safil;

--
-- Name: resolution_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.resolution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resolution_id_seq OWNER TO safil;

--
-- Name: resolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.resolution_id_seq OWNED BY public.resolution.id;


--
-- Name: retraining; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.retraining (
    id integer NOT NULL,
    alarmid integer NOT NULL,
    isenabledforretraining timestamp without time zone,
    retrainingdate date,
    status character varying(100)
);


ALTER TABLE public.retraining OWNER TO safil;

--
-- Name: retraining_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.retraining_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.retraining_id_seq OWNER TO safil;

--
-- Name: retraining_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.retraining_id_seq OWNED BY public.retraining.id;


--
-- Name: userallocation; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.userallocation (
    id integer NOT NULL,
    pipelineconfigfrom double precision NOT NULL,
    pipelineconfigto double precision NOT NULL,
    roumarkerfrom text NOT NULL,
    roumarkerto text NOT NULL,
    "userId" integer,    
    "usertypeId" integer NOT NULL,
    "rouId" integer,
    "crmId" integer,   
    "supervisorId" integer,
    "regioninfoId" integer
    
);



ALTER TABLE public.userallocation OWNER TO safil;

--
-- Name: userallocation_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.userallocation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.userallocation_id_seq OWNER TO safil;

--
-- Name: userallocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.userallocation_id_seq OWNED BY public.userallocation.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.users (
    id integer NOT NULL,
    firstname text NOT NULL,
    lastname text NOT NULL,
    password text NOT NULL,
    cellphone character varying(15) NOT NULL,
    email text NOT NULL,
    permission text NOT NULL,
    address text,
    gender text,
    employeeid integer,
    isverified boolean DEFAULT false,
    ispasswordchange boolean DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "usertypeId" integer NOT NULL,
    reportpids text[]
);


ALTER TABLE public.users OWNER TO safil;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO safil;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: usertype; Type: TABLE; Schema: public; Owner: safil
--

CREATE TABLE public.usertype (
    id integer NOT NULL,
    usertype character varying(100),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.usertype OWNER TO safil;

--
-- Name: usertype_id_seq; Type: SEQUENCE; Schema: public; Owner: safil
--

CREATE SEQUENCE public.usertype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usertype_id_seq OWNER TO safil;

--
-- Name: usertype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safil
--

ALTER SEQUENCE public.usertype_id_seq OWNED BY public.usertype.id;


--
-- Name: acknowledgement id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.acknowledgement ALTER COLUMN id SET DEFAULT nextval('public.acknowledgement_id_seq'::regclass);


--
-- Name: channelinfo id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.channelinfo ALTER COLUMN id SET DEFAULT nextval('public.channelinfo_id_seq'::regclass);


--
-- Name: dashboard id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.dashboard ALTER COLUMN id SET DEFAULT nextval('public.dashboard_id_seq'::regclass);


--
-- Name: fibreshotmonitoring id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.fibreshotmonitoring ALTER COLUMN id SET DEFAULT nextval('public.fibreshotmonitoring_id_seq'::regclass);


--
-- Name: pidsconfiglog id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsconfiglog ALTER COLUMN id SET DEFAULT nextval('public.pidsconfiglog_id_seq'::regclass);


--
-- Name: pidsinfo id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsinfo ALTER COLUMN id SET DEFAULT nextval('public.pidsinfo_id_seq'::regclass);


--
-- Name: pidsstatus id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsstatus ALTER COLUMN id SET DEFAULT nextval('public.pidsstatus_id_seq'::regclass);


--
-- Name: pigtracking id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pigtracking ALTER COLUMN id SET DEFAULT nextval('public.pigtracking_id_seq'::regclass);


--
-- Name: pipelineconfig id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pipelineconfig ALTER COLUMN id SET DEFAULT nextval('public.pipelineconfig_id_seq'::regclass);


--
-- Name: ramanmandialarm id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandialarm ALTER COLUMN id SET DEFAULT nextval('public.ramanmandialarm_id_seq'::regclass);


--
-- Name: ramanmandieventconfirmed id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandieventconfirmed ALTER COLUMN id SET DEFAULT nextval('public.ramanmandieventconfirmed_id_seq'::regclass);


--
-- Name: ramanmandifibreshot id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandifibreshot ALTER COLUMN id SET DEFAULT nextval('public.ramanmandifibreshot_id_seq'::regclass);


--
-- Name: ramanmandiramanmandipredictedevents id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandiramanmandipredictedevents ALTER COLUMN id SET DEFAULT nextval('public.ramanmandipredictedevents_id_seq'::regclass);


--
-- Name: regioninfo id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.regioninfo ALTER COLUMN id SET DEFAULT nextval('public.regioninfo_id_seq'::regclass);


--
-- Name: resolution id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.resolution ALTER COLUMN id SET DEFAULT nextval('public.resolution_id_seq'::regclass);


--
-- Name: retraining id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.retraining ALTER COLUMN id SET DEFAULT nextval('public.retraining_id_seq'::regclass);


--
-- Name: userallocation id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.userallocation ALTER COLUMN id SET DEFAULT nextval('public.userallocation_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: usertype id; Type: DEFAULT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.usertype ALTER COLUMN id SET DEFAULT nextval('public.usertype_id_seq'::regclass);


--
-- Name: acknowledgement acknowledgement_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.acknowledgement
    ADD CONSTRAINT acknowledgement_pkey PRIMARY KEY (id);


--
-- Name: channelinfo channelinfo_ix1; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.channelinfo
    ADD CONSTRAINT channelinfo_ix1 UNIQUE (name, "pidsinfoId", "channelId");


--
-- Name: channelinfo channelinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.channelinfo
    ADD CONSTRAINT channelinfo_pkey PRIMARY KEY (id);


--
-- Name: dashboard dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT dashboard_pkey PRIMARY KEY (id);


--
-- Name: fibreshotmonitoring fibreshotmonitoring_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.fibreshotmonitoring
    ADD CONSTRAINT fibreshotmonitoring_pkey PRIMARY KEY (id);


--
-- Name: pidsconfiglog pidsconfiglog_ix1; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsconfiglog
    ADD CONSTRAINT pidsconfiglog_ix1 UNIQUE (datetime);


--
-- Name: pidsconfiglog pidsconfiglog_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsconfiglog
    ADD CONSTRAINT pidsconfiglog_pkey PRIMARY KEY (id);


--
-- Name: pidsinfo pidsinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsinfo
    ADD CONSTRAINT pidsinfo_pkey PRIMARY KEY (id);


--
-- Name: pidsinfo pidsinfo_unique_key; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsinfo
    ADD CONSTRAINT pidsinfo_unique_key UNIQUE (name, ipaddress);


--
-- Name: pidsstatus pidsstatus_ix1; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsstatus
    ADD CONSTRAINT pidsstatus_ix1 UNIQUE (date);


--
-- Name: pidsstatus pidsstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsstatus
    ADD CONSTRAINT pidsstatus_pkey PRIMARY KEY (id);


--
-- Name: pigtracking pigtracking_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pigtracking
    ADD CONSTRAINT pigtracking_pkey PRIMARY KEY (id);


--
-- Name: pipelineconfig pipelineconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pipelineconfig
    ADD CONSTRAINT pipelineconfig_pkey PRIMARY KEY (id);


--
-- Name: ramanmandialarm ramanmandialarm_ix1; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandialarm
    ADD CONSTRAINT ramanmandialarm_ix1 UNIQUE (datetime);


--
-- Name: ramanmandialarm ramanmandialarm_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandialarm
    ADD CONSTRAINT ramanmandialarm_pkey PRIMARY KEY (id);


--
-- Name: ramanmandieventconfirmed ramanmandieventconfirmed_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandieventconfirmed
    ADD CONSTRAINT ramanmandieventconfirmed_pkey PRIMARY KEY (id);


--
-- Name: ramanmandifibreshot ramanmandifibreshot_ix1; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandifibreshot
    ADD CONSTRAINT ramanmandifibreshot_ix1 UNIQUE (fibreshottime, "channelId");


--
-- Name: ramanmandifibreshot ramanmandifibreshot_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandifibreshot
    ADD CONSTRAINT ramanmandifibreshot_pkey PRIMARY KEY (id);


--
-- Name: ramanmandiramanmandipredictedevents ramanmandipredictedevents_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandiramanmandipredictedevents
    ADD CONSTRAINT ramanmandipredictedevents_pkey PRIMARY KEY (id);


--
-- Name: regioninfo regioninfo_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.regioninfo
    ADD CONSTRAINT regioninfo_pkey PRIMARY KEY (id);


--
-- Name: resolution resolution_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.resolution
    ADD CONSTRAINT resolution_pkey PRIMARY KEY (id);


--
-- Name: retraining retraining_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.retraining
    ADD CONSTRAINT retraining_pkey PRIMARY KEY (id);


--
-- Name: userallocation userallocation_ix1; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.userallocation
    ADD CONSTRAINT userallocation_ix1 UNIQUE (pipelineconfigfrom, pipelineconfigto, roumarkerfrom, roumarkerto);


--
-- Name: userallocation userallocation_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.userallocation
    ADD CONSTRAINT userallocation_pkey PRIMARY KEY (id);


--
-- Name: users users_ix1; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_ix1 UNIQUE (firstname, lastname, cellphone, email, permission);


--
-- Name: users users_ix2; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_ix2 UNIQUE (employeeid);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: usertype usertype_ix1; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.usertype
    ADD CONSTRAINT usertype_ix1 UNIQUE (usertype);


--
-- Name: usertype usertype_pkey; Type: CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.usertype
    ADD CONSTRAINT usertype_pkey PRIMARY KEY (id);


--
-- Name: channelinfo_id_idx; Type: INDEX; Schema: public; Owner: safil
--

CREATE INDEX channelinfo_id_idx ON public.channelinfo USING btree (id);


--
-- Name: idx_regioninfo_id; Type: INDEX; Schema: public; Owner: safil
--

CREATE INDEX idx_regioninfo_id ON public.regioninfo USING btree (id);


--
-- Name: pidsinfo_id_idx; Type: INDEX; Schema: public; Owner: safil
--

CREATE INDEX pidsinfo_id_idx ON public.pidsinfo USING btree (id);


--
-- Name: ramanmandieventconfirmed_idx_datetime; Type: INDEX; Schema: public; Owner: safil
--

CREATE INDEX ramanmandieventconfirmed_idx_datetime ON public.ramanmandieventconfirmed USING btree (datetime);


--
-- Name: ramanmandieventconfirmed_idx_eventdate; Type: INDEX; Schema: public; Owner: safil
--

CREATE INDEX ramanmandieventconfirmed_idx_eventdate ON public.ramanmandieventconfirmed USING btree (eventdate);


--
-- Name: ramanmandieventconfirmed_idx_eventtime; Type: INDEX; Schema: public; Owner: safil
--

CREATE INDEX ramanmandieventconfirmed_idx_eventtime ON public.ramanmandieventconfirmed USING btree (eventtime);


--
-- Name: ramanmandifibreshot partition_insert_trigger; Type: TRIGGER; Schema: public; Owner: safil
--

CREATE TRIGGER partition_insert_trigger BEFORE INSERT ON public.ramanmandifibreshot FOR EACH ROW EXECUTE FUNCTION public.create_partition_and_insert();


--
-- Name: acknowledgement acknowledgement_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.acknowledgement
    ADD CONSTRAINT acknowledgement_fk1 FOREIGN KEY ("pidsinfoId") REFERENCES public.pidsinfo(id);


--
-- Name: channelinfo channelinfo_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.channelinfo
    ADD CONSTRAINT channelinfo_fk1 FOREIGN KEY ("pidsinfoId") REFERENCES public.pidsinfo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: channelinfo channelinfo_fk2; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.channelinfo
    ADD CONSTRAINT channelinfo_fk2 FOREIGN KEY ("regioninfoId") REFERENCES public.regioninfo(id);


--
-- Name: dashboard dashboard_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT dashboard_fk1 FOREIGN KEY ("regeoninfoId") REFERENCES public.regioninfo(id);


--
-- Name: fibreshotmonitoring fibreshotmonitoring_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.fibreshotmonitoring
    ADD CONSTRAINT fibreshotmonitoring_fk1 FOREIGN KEY ("pidsinfoId") REFERENCES public.pidsinfo(id);


--
-- Name: pidsconfiglog pidsconfiglog_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsconfiglog
    ADD CONSTRAINT pidsconfiglog_fk1 FOREIGN KEY ("pidsinfoId") REFERENCES public.pidsinfo(id);


--
-- Name: pidsstatus pidsstatus_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pidsstatus
    ADD CONSTRAINT pidsstatus_fk1 FOREIGN KEY ("pidsinfoId") REFERENCES public.pidsinfo(id);


--
-- Name: pigtracking pigtracking_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pigtracking
    ADD CONSTRAINT pigtracking_fk1 FOREIGN KEY ("channelId") REFERENCES public.channelinfo(id);


--
-- Name: pipelineconfig pipelineconfig_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pipelineconfig
    ADD CONSTRAINT pipelineconfig_fk1 FOREIGN KEY ("channelId") REFERENCES public.channelinfo(id);


--
-- Name: pipelineconfig pipelineconfig_fk2; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.pipelineconfig
    ADD CONSTRAINT pipelineconfig_fk2 FOREIGN KEY ("regioninfoId") REFERENCES public.regioninfo(id);


--
-- Name: ramanmandialarm ramanmandialarm_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandialarm
    ADD CONSTRAINT ramanmandialarm_fk1 FOREIGN KEY ("pipelineconfigId") REFERENCES public.pipelineconfig(id);


--
-- Name: ramanmandieventconfirmed ramanmandieventconfirmed_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandieventconfirmed
    ADD CONSTRAINT ramanmandieventconfirmed_fk1 FOREIGN KEY ("pipelineconfigId") REFERENCES public.pipelineconfig(id);


--
-- Name: ramanmandiramanmandipredictedevents ramanmandiramanmandipredictedevents_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.ramanmandiramanmandipredictedevents
    ADD CONSTRAINT ramanmandiramanmandipredictedevents_fk1 FOREIGN KEY ("pipelineconfigId") REFERENCES public.pipelineconfig(id);


--
-- Name: resolution resolution_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.resolution
    ADD CONSTRAINT resolution_fk1 FOREIGN KEY ("pidsinfoId") REFERENCES public.pidsinfo(id);


--
-- Name: userallocation userallocation_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.userallocation
    ADD CONSTRAINT userallocation_fk1 FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: users users_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_fk1 FOREIGN KEY ("usertypeId") REFERENCES public.usertype(id);


--
-- Name: userallocation usertype_fk1; Type: FK CONSTRAINT; Schema: public; Owner: safil
--

ALTER TABLE ONLY public.userallocation
    ADD CONSTRAINT usertype_fk1 FOREIGN KEY ("usertypeId") REFERENCES public.usertype(id);


--
-- PostgreSQL database dump complete
--

