CREATE OR REPLACE FUNCTION next_uuid(OUT result uuid) AS $$
DECLARE
    now_micros bigint;
    second_rand bigint;
    hex_value text;
    shard_id int:=1;
    version int:=7;
BEGIN
    -- Can use clock_timestamp() / statement_timestamp() / transaction_timestamp() / current_timestamp
    select (extract(epoch from current_timestamp)*1000000)::BIGINT INTO now_micros;
    -- Uncomment one of below lines to ignore sharding.
    -- shard_id := now_micros%1000;
    -- select ((random() * 10^6)::INT) INTO shard_id;

    -- [milliseconds(6 bytes) + microseconds(12 bits) + shard(4 bits) + random(8 bytes)]
    -- select ((random() * 10^18)::BIGINT) INTO second_rand;
    -- hex_value := LPAD(TO_HEX(now_micros/1000), 12, '0')||LPAD(TO_HEX(now_micros%1000), 3, '0')||LPAD(TO_HEX(shard_id), 1, '0')||LPAD(TO_HEX(second_rand), 16, '0'); 

    -- UUID v7: [milliseconds(6 bytes) + version(4 bits) + microseconds/shard(12 bits)+ var(2 bits) + random(62 bits)]
    select (((random() * 10^18)::BIGINT) & x'3FFFFFFFFFFFFFFF'::BIGINT) |x'8000000000000000'::BIGINT INTO second_rand;
    hex_value := LPAD(TO_HEX(now_micros/1000), 12, '0')||LPAD(TO_HEX(version), 1, '0')||LPAD(TO_HEX(shard_id), 3, '0')||LPAD(TO_HEX(second_rand), 16, '0');
    result := CAST(hex_value AS UUID);
    -- TEST PERFOMANCE
    -- EXPLAIN ANALYZE
    -- SELECT next_uuid() FROM generate_series(1,100000);
END;
$$ LANGUAGE PLPGSQL;
