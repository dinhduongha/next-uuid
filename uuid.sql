CREATE OR REPLACE FUNCTION next_uuid(OUT result uuid) AS $$
DECLARE
    now_millis bigint;
    second_rand bigint;
    hex_value text;
    shard_id int:=1;
BEGIN
    -- Can use clock_timestamp() / statement_timestamp()
    select (extract(epoch from transaction_timestamp())*1000)::BIGINT+(extract(milliseconds from transaction_timestamp()))::BIGINT INTO now_millis;
    select ((random() * 10^18)::BIGINT) INTO second_rand;
    -- Uncomment below line to ignore sharding.
    -- select ((random() * 10^6)::INT) INTO shard_id;
    hex_value := RPAD(TO_HEX(now_millis), 12, '0')||LPAD(TO_HEX(shard_id), 4, '0')||LPAD(TO_HEX(second_rand), 16, '0');
    result := CAST(hex_value AS UUID);
END;
$$ LANGUAGE PLPGSQL;
