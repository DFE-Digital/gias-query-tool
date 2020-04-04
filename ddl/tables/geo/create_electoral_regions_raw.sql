create table electoral_regions_raw (
    ogc_fid integer not null,
    eer13cd character varying,
    eer13cdo character varying,
    eer13nm character varying,
    wkb_geometry geometry(Geometry, 4326)
);
