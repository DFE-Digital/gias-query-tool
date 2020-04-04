create table local_authority_districts_raw (
    ogc_fid integer not null,
    id character varying,
    lad13cd character varying,
    lad13cdo character varying,
    lad13nm character varying,
    lad13nmw character varying,
    wkb_geometry geometry(Geometry, 4326)
);
