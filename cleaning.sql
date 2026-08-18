-- KICKSTARTER DATASET CLEANING
-- 1. cek data awal
  select * from projects;
  select count(*) as jumlah_data from projects;
    
-- 2. cek duplikat data
-- cek id yang duplikat
  select id, count(*) as jumlah
  from projects group by id having count(*) > 1;
-- cek duplikat berdasarkan seluruh kolom
  with duplikat as (
  select *,
  row_number() over(
  partition by id, name, category, main_category, currency,
  deadline, goal, launched, pledged, state, backers, country,
  usd_pledged, usd_pledged_real, usd_goal_real) as row_num from projects )
  select * from duplikat where row_num > 1;

-- 3. ubah tipe data menjadi decimal
  alter table projects modify column goal decimal(15,2);
  alter table projects modify column pledged decimal(15,2);
  alter table projects modify column usd_pledged_real decimal(15,2);
  alter table projects modify column usd_goal_real decimal(15,2);
    
-- 4. cek missing value atau data yang terisi string/spasi kosong pada kolom yang akan digunakan analisis
  select
	sum(case when main_category is null or trim(main_category) = '' then 1 else 0 end) as main_category_kosong,
	sum(case when category is null or trim(category) = '' then 1 else 0 end) as category_kosong,
	sum(case when state is null or trim(state) = '' then 1 else 0 end) as state_kosong,
	sum(case when launched is null then 1 else 0 end) as launched_kosong,
	sum(case when deadline is null then 1 else 0 end) as deadline_kosong,
	sum(case when usd_goal_real is null then 1 else 0 end) as usd_goal_real_kosong
  from projects;

-- 5. cek dan menangani kategori country yang anomali
	select country, count(*) as jumlah from projects
	where country = 'N,0""' group by country;
-- ubah kategori country anomali menjadi Unknown
	update projects set country = 'Unknown'
	where country = 'N,0""';

-- 6. cek konsistensi tanggal
-- cek apakah ada deadline yang lebih awal dari launched
	select id, name, deadline, launched
	from projects
	where deadline < date(launched);

-- cek campaign dengan durasi lebih dari 100 hari
	select id, launched, deadline,
	datediff(deadline, date(launched)) as jumlah_hari
	from projects where datediff(deadline, date(launched)) >= 100; 

-- 7. cek dan menghapus data tahun 1970
	select id, launched, deadline,
	datediff(deadline, date(launched)) as jumlah_hari
	from projects where year(launched) = 1970;
-- terdapat 7 data dengan tahun launched 1970 dan menghasilkan durasi campaign yang tidak wajar
	delete from projects where year(launched) = 1970; -- data dihapus karena berada di luar periode data
    
-- 8. cek nilai yang tidak wajar
	select goal, pledged, backers, usd_pledged, usd_pledged_real, usd_goal_real
	from projects where goal = 0 or pledged <= 0 or backers <= 0 or usd_pledged <= 0
	or usd_pledged_real <= 0 or usd_goal_real = 0;
    
-- 9. cek apakah ada proyek successful tetapi pledged < goal
	select id, state, goal, pledged, usd_goal_real, usd_pledged_real
	from projects where state = 'successful' and pledged < goal;

-- cek jumlah data setelah cleaning
	select count(*) as jumlah_data_setelah_cleaning from projects;
-- cek apakah country anomali masih ada
	select count(*) as jumlah_country_anomali
	from projects where country = 'N,0""';
-- cek apakah data tahun 1970 masih ada
	select count(*) as jumlah_data_1970
	from projects where year(launched) = 1970;
