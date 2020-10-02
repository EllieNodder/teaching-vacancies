SELECT
  school.id AS id,
  school.name AS name,
  school.urn AS urn,
  school.phase AS phase,
  school.url AS url,
  school.minimum_age AS minimum_age,
  school.maximum_age AS maximum_age,
  school.address,
  school.town,
  school.county,
  school.postcode,
  school.local_authority AS local_authority,
  school.locality AS locality,
  school.address3 AS address3,
  #put a full address together from its components so we only have to do this in one place
  CONCAT(IFNULL(CONCAT(school.address,"\n"),
      ""),IFNULL(CONCAT(school.locality,"\n"),
      ""),IFNULL(CONCAT(school.address3,"\n"),
      ""),IFNULL(CONCAT(school.town,"\n"),
      ""),IFNULL(CONCAT(school.county,"\n"),
      ""),IFNULL(school.postcode,
      "")) AS full_address,
  school.easting AS easting,
  school.northing,
  #flatten out these three reference data ID fields so we can also access their labels and codes
  school.school_type_id,
  schooltype.label AS school_type,
  schooltype.code AS school_type_code,
  school.region_id,
  region.name AS region,
  region.code AS region_code,
  school.detailed_school_type_id,
  detailedschooltype.code AS detailed_school_type_code,
  detailedschooltype.label AS detailed_school_type,
  #work out whether each school has an in scope type and record this so we only have to do this in one place
  CAST(detailedschooltype.code AS NUMERIC) IN (
  SELECT
    code
  FROM
    `teacher-vacancy-service.production_dataset.STATIC_establishment_types_in_scope`) AS detailed_school_type_in_scope,
  CAST(school.created_at AS DATE) AS date_created,
  CAST(school.updated_at AS DATE) AS date_updated,
  school.geolocation_x,
  school.geolocation_y,
  ST_GEOGPOINT(school.geolocation_x,
    school.geolocation_y) AS geolocation,
  school.data_administrativeward_name AS administrative_ward,
  school.data_admissionspolicy_name AS admissions_policy,
  school.data_bsoinspectoratename_name AS bso_inspectorate_name,
  school.data_boarders_name AS boarders,
  school.data_boardingestablishment_name AS boarding_establishment,
  school.data_ccf_name AS ccf,
  school.data_censusareastatisticward_name AS census_area_statistic_ward,
  school.data_censusdate AS census_date,
  school.data_closedate AS date_closed,
  school.data_country_name AS country,
  school.data_dateoflastinspectionvisit AS date_last_inspected,
  school.data_diocese_name AS diocese,
  school.data_districtadministrative_name AS administrative_district,
  school.data_ebd_name AS ebd,
  school.data_edbyother_name AS ed_by_other,
  school.data_establishmentstatus_name AS status,
  school.data_establishmenttypegroup_name AS establishment_type_group,
  school.data_feheidentifier AS fe_he_identifier,
  school.data_ftprov_name AS ft_provider,
  school.data_federations_name AS federation,
  school.data_furthereducationtype_name AS fe_type,
  school.data_gor_name AS gor,
  school.data_gsslacode_name AS gssla_code,
  school.data_gender_name AS gender,
  school.data_headfirstname AS head_first_name,
  school.data_headlastname AS head_last_name,
  school.data_headpreferredjobtitle AS head_job_title,
  school.data_headtitle_name AS head_title,
  REPLACE(TRIM(school.data_headtitle_name || " " || school.data_headfirstname || " " || school.data_headlastname),"  "," ") AS head,
  school.data_inspectoratename_name AS inspectorate,
  school.data_inspectoratereport AS inspectorate_report,
  school.data_lsoa_name AS lsoa,
  school.data_lastchangeddate AS date_last_changed,
  school.data_msoa_name AS msoa,
  school.data_nextinspectionvisit AS next_inspection_visit,
  school.data_numberofboys AS number_of_boys,
  school.data_numberofgirls AS number_of_girls,
  school.data_numberofpupils AS number_of_pupils,
  school.data_nurseryprovision_name AS nursery_provision,
  school.data_officialsixthform_name AS official_sixth_form,
  school.data_ofstedlastinsp AS ofsted_last_insp,
  school.data_ofstedrating_name AS ofsted_rating,
  school.data_ofstedspecialmeasures_name AS ofsted_special_measures,
  school.data_opendate AS date_opened,
  school.data_parliamentaryconstituency_name AS parliamentary_constituency,
  school.data_percentagefsm AS percentage_fsm,
  school.data_phaseofeducation_name AS education_phase,
  school.data_placespru AS places_pru,
  school.data_previousestablishmentnumber AS previous_establishment_number,
  school.data_previousla_name AS previous_la,
  school.data_propsname AS props_name,
  school.data_rscregion_name AS rsc_region,
  school.data_reasonestablishmentclosed_name AS reason_closed,
  school.data_reasonestablishmentopened_name AS reason_opened,
  school.data_religiouscharacter_name AS religious_character,
  school.data_religiousethos_name AS religious_ethos,
  school.data_resourcedprovisioncapacity AS resourced_provision_capacity,
  school.data_resourcedprovisiononroll AS resourced_provision_on_roll,
  school.data_schoolcapacity AS capacity,
  school.data_schoolsponsorflag_name AS sponsor_flag,
  school.data_schoolsponsors_name AS sponsors,
  school.data_schoolwebsite AS website,
  school.data_sitename AS site,
  school.data_specialclasses_name AS special_classes,
  school.data_statutoryhighage AS statutory_high_age,
  school.data_statutorylowage AS statutory_low_age,
  school.data_teenmoth_name AS teenage_mothers,
  school.data_teenmothplaces AS teenage_mothers_places,
  school.data_telephonenum AS telephone_number,
  school.data_trustschoolflag_name AS trusts_school_flag,
  school.data_typeofestablishment_name AS type_of_establishment,
  school.data_typeofresourcedprovision_name AS type_of_resourced_provision,
  school.data_ukprn AS ukprn,
  school.data_uprn AS uprn,
  school.data_urbanrural_name AS urban_rural
FROM
  `teacher-vacancy-service.production_dataset.feb20_organisation` AS school
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_schooltype` AS schooltype
ON
  school.school_type_id=schooltype.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_region` AS region
ON
  school.region_id=region.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_detailedschooltype` AS detailedschooltype
ON
  school.detailed_school_type_id=detailedschooltype.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
ON
  schoolgroupmembership.school_id = school.id
WHERE
  school.type="School" #excludes organisations which aren't schools, like School Groups i.e. MATs
