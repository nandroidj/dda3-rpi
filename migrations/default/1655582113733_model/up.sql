-- SET check_function_bodies = false;
-- CREATE SCHEMA public;

CREATE TABLE public.telemetries (
  id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  device_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
  temperature integer NOT NULL,
  humidity integer NOT NULL
);

CREATE TABLE public.commands (
  id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  device_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  command text,
  parameter integer
);

CREATE TABLE public.devices (
  id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  name text
);


-- Primary keys
ALTER TABLE ONLY public.telemetries
    ADD CONSTRAINT telemetries_id_key UNIQUE (id);

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_id_key UNIQUE (id);

-- Foreign keys
ALTER TABLE ONLY public.telemetries
    ADD CONSTRAINT telemetries_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
    
ALTER TABLE ONLY public.commands
    ADD CONSTRAINT commands_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
