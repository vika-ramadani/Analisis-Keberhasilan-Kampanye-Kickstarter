# Analisis Keberhasilan Kampanye Kickstarter
## Gambaran Dataset
Kickstarter merupan platform crowdfunding yang memungkinkan kreator menggalang dana untuk berbagai proyek kreatif melalui dukungan dari publik. Datasetnya berisi informasi mengenai ratusan ribu campaign(kampanye) yang diluncurkan melalui platformnya, termasuk kategori proyek, jumlah pendukung, waktu peluncuran, tenggan campaign, serta status akhir proyek. Dataset ini mencangkup periode April 2009 - Januari 2018 dengan beberapa kolom utama berikut:
<img width="720" height="467" alt="image" src="https://github.com/user-attachments/assets/31128477-4489-4d82-9fbe-3efd2d73f29e" />

**Sumber Dataset:** [Kaggle – Kickstarter Projects](https://www.kaggle.com/datasets/kemical/kickstarter-projects?select=ks-projects-201801.csv)
<img width="1818" height="884" alt="image" src="https://github.com/user-attachments/assets/aa0fd795-73c9-48fd-8897-73465b574538" />

## Permasalahan Bisnis
Dalam proyek ini, saya mengeksplorasi data campaign Kickstarter untuk mengidentifikasi karakteristik yang berkaitan dengan keberhasilan dan kegagalan proyek. Permasalahan bisnis yang ingin dijawab adalah bagaimana **kategori proyek, target pendanaan, waktu peluncuran, dan durasi campaign** berkaitan dengan tingkat keberhasilan campaign, sehingga dapat diketahui pola yang dapat menjadi pertimbangan dalam menentukan strategi campaign yang lebih tepat.

## Tujuan Analisis
Proyek ini bertujuan untuk menganalisis pola keberhasilan dan kegagalan kampanye Kickstarter berdasarkan target pendanaan, waktu peluncuran, dan durasi kampanye.

## Data Cleaning
Melakukan pengecekan kualitas data untuk mengidentifikasi nilai kosong, data anomali, ketidaksesuaian tipe data, serta nilai yang tidak konsisten. Berikut permasalahan yang ditemukan dalam data dan penanganan yang saya lakukan.
<img width="1218" height="348" alt="image" src="https://github.com/user-attachments/assets/98b97433-12eb-426a-a115-be7631d9446a" />

## Data Transformasi
Setelah proses cleaning, saya melakukan  transformasi untuk menghasilkan variabel yang lebih mudah digunakan dalam analisis.
1. **Target pendanaan** menggunakan kolom `usd_goal_real` karena seluruh proyek dapat dibandingkan dalam satu mata uang yaitu USD. Kemudian dilakukan pengelompokan menjadi 5 kategori untuk melihat hubungan antara besarnya target pendanaan dan tingkat keberhasilan.
   
   <img width="285" height="224" alt="image" src="https://github.com/user-attachments/assets/a1608cdd-86ed-4490-9427-a0def4ae1be2" />

2. Durasi Campaign dihitung menggunakan selisih antara tanggal di kolom `deadline` dan `launched`. Durasi kemudan dikelompokkan menjadi 5 kategori.
   
   <img width="210" height="224" alt="image" src="https://github.com/user-attachments/assets/54954f26-4f09-41ef-88aa-dd65939c53a4" />

3. Mengukur performa campaign dengan membuat metrik **Success Rate** dengan membandingkan jumlah proyek `successful` terhadap seluruh proyek yang `successful` dan `failed`.
***Success Rate =  Successful / (Successful + failed) * 100%***.

## Exploratory Data Analysis
Pada tahap analisis ini, saya menggunakan 6 kolom yang akan digunakan untuk menjawab permasalahan bisnis diantarnya:
1. `main_category` : untuk menganalisis success rate berdasarkan kategori.
2. `category` : untuk melihat detail subkategori dari masing-masing kategori.
3. `usd_goal_real` : untuk menganalisis hubungan target pendanaan dengan success rate.
4. `launched` : menganalisis tren tahunan dan bulanan dan dasar perhitungan durasi.
5. `deadline` : perhitungan durasi campaign.
6. `state` : menentukan proyek `successful` dan `failed` serta menghitung success rate.

**Proses Analisis:**
1. Keberhasilan Berdasarkan Kategori

   Bagaimana tingkat keberhasilan campaign berdasarkan kategori proyek dan apakah perbedaan tingkat keberhasilan antar kategori berkaitan dengan perbedaan rata-rata target pendanaan?.
   ```sql
   select
     main_category, 
    concat(round(sum(case when state = 'successful' then 1 else 0 end) * 100 / count(*), 1), '%') as rate_success,
   concat('$',round(avg(usd_goal_real),2)) as ratarata_target_kampanye
   from projects where state in ('successful','failed') group by main_category order by rate_success desc;
   ```
   <img width="508" height="427" alt="image" src="https://github.com/user-attachments/assets/eb060efc-cdd7-4fdd-b3c8-d472fad4d020" />

   Berdasarkan output, tingkat keberhasilan berbeda cukup signifikan antar kategori. Dance memiliki tingkat keberhasilan tertinggi sebesar 65,4%, diikuti Theater sebesar 63,8%, sedangkan Journalism (24,4%) dan Technology (23,8%) berada pada tingkat terendah.
   
   Perbandingan dengan rata-rata target pendanaan menunjukkan bahwa target pendanaan dapat menjadi salah satu karakteristik yang berkaitan dengan keberhasilan, tetapi tidak sepenuhnya menjelaskan perbedaan antar kategori. Sebagai contoh, Film & Video memiliki rata-rata target pendanaan sekitar $76 ribu, tetapi success rate mencapai 41,8%, lebih tinggi dibandingkan Crafts yang memiliki success rate 27,1% dengan target pendanaan yang cukup rendah yaitu $9 ribu.


2. Target Pendanaan dan Keberhasilan
   
   Bagaimana tingkat keberhasilan berdasarkan kelompok target pendanaan? Apakah target pendanaan yang lebih rendah memiliki tingkat keberhasilan campaign yang lebih tinggi?
   ```sql
   select
   case when usd_goal_real < 2000 then 'Sangat Rendah'
    when usd_goal_real < 5000 then 'Rendah'
    when usd_goal_real < 15000 then 'Menengah'
    when usd_goal_real < 50000 then 'Tinggi'
    else 'Sangat Tinggi' end as target_pendanaan,
    count(*) as jumlah_project, 
    concat(round(sum(case when state = 'successful' then 1 else 0 end) * 100 / count(*), 1), '%') as rate_success
    from projects where state in ('successful','failed')
    group by target_pendanaan order by rate_success desc;
   ```
   
   <img width="450" height="165" alt="image" src="https://github.com/user-attachments/assets/4417d132-bd9d-44a9-8d81-94169efefe95" />

   Hasil analisis menunjukkan pola yang konsisten antara target pendanaan dan tingkat keberhasilan. Kelompok sangat rendah (< $2.000) memiliki success rate tertinggi sebesar 52,9%, sedangkan kelompok sangat tinggi (≥ $50.000) memiliki success rate terendah sebesar 15,0%. Tingkat keberhasilan juga menunjukkan bahwa kampanye dengan target pendanaan yang lebih rendah cenderung memiliki tingkat keberhasilan yang lebih tinggi dibandingkan kampanye dengan target pendanaan yang lebih besar. 

3. Tren Keberhasilan dari Waktu ke Waktu

   a. Perubahan jumlah proyek Kickstarter dari tahun ke tahun.
   ```sql
   select
   year(launched) as Tahun,
   count(*) as jumlah_proyek from projects where state in ('successful','failed') group by year(launched) order by Tahun;
   ```
   <img width="241" height="259" alt="image" src="https://github.com/user-attachments/assets/1b3cb2ab-6962-489b-aedc-70094b0f65ce" />

   Jumlah proyek menunjukkan tren peningkatan sejak 2009 hingga 2015, dari 1.179 proyek pada 2009 hingga mencapai puncaknya sebanyak 59.306 proyek pada 2015. Setelah mencapai puncak tersebut, jumlah proyek mulai menurun pada 2016 dan 2017.
   
  Tahun 2018 tidak digunakan dalam analisis tren tahunan karena data yang tersedia hanya mencakup bulan Januari, sehingga belum merepresentasikan satu tahun penuh dan belum terdapat proyek yang tercatat dengan status successful maupun failed.

   b. Bagaimana persebaran jumlah proyek yang sukses dan gagal, dan tingkat keberhasilan dari tahun ke tahun?
   ```sql
   select year(launched) as Tahun, 
    sum(case when state = 'successful' then 1 else 0 end) as jumlah_success,
    sum(case when state = 'failed' then 1 else 0 end) as jumlah_failed,
    concat(round(sum(case when state = 'successful' then 1 else 0 end) * 100 / count(*), 1), '%') as rate_success
   from projects
   where state in ('successful','failed') group by year(launched) order by year(launched);
   ```
   <img width="484" height="265" alt="image" src="https://github.com/user-attachments/assets/5189a10b-4e48-43fe-b368-d743d1f5ddf4" />

   Tingkat keberhasilan tidak menunjukkan tren peningkatan atau penurunan yang konsisten, tetapi berfluktuasi dari tahun ke tahun. Pada periode 2009-2013, success rate berada pada kisaran 46–51%, kemudian mengalami penurunan pada 2014–2015 hingga mencapai titik terendah sebesar 32,1% pada 2015. Setelah itu, tingkat keberhasilan kembali meningkat pada 2016 dan 2017, masing-masing menjadi 38,1% dan 42,5%.
  Secara keseluruhan, success rate selama periode analisis berada pada rentang 32,1%-50,6%, sehingga perubahan jumlah proyek dari tahun ke tahun tidak secara langsung menunjukkan peningkatan tingkat keberhasilan campaign.

   c. Tingkat keberhasilan berdasarkan durasi campaign(kampanye) proyek.
   ```sql
   select case
   when datediff(deadline, date(launched)) <= 15 then 'Sangat Singkat'
   when datediff(deadline, date(launched)) <= 30 then 'Singkat'
   when datediff(deadline, date(launched)) <= 45 then 'Sedang'
   when datediff(deadline, date(launched)) <= 60 then 'Panjang'
   else 'Sangat Panjang' end as durasi,
   count(*) as jumlah_proyek,
   sum(case when state = 'successful' then 1 else 0 end) as proyek_sukses,
   sum(case when state = 'failed' then 1 else 0 end) as proyek_gagal,
   concat(round(sum(case when state = 'successful' then 1 else 0 end) * 100 / count(*)), '%') as rate_sukses
   from projects where state in ('successful','failed') group by durasi order by min(datediff(deadline, DATE(launched)));
   ```
   <img width="673" height="162" alt="image" src="https://github.com/user-attachments/assets/44c4d5bc-a9b0-4647-9bb2-fa1d990c03be" />
   Hasil analisis menunjukkan bahwa tingkat keberhasilan berbeda antar kelompok durasi. Campaign dengan durasi sangat singkat (<=15 hari) memiliki success rate tertinggi sebesar 50%, sedangkan campaign dengan durasi panjang (46-60 hari) memiliki success rate terendah sebesar 27%.
   Pola tersebut tidak sepenuhnya linear. Success rate menurun pada campaign berdurasi 16-30 hari dan kembali meningkat pada 31-45 hari, kemudian mencapai titik terendah pada 46-60 hari dan kembali meningkat menjadi 39% pada campaign lebih dari 60 hari. Dengan demikian, durasi campaign memiliki perbedaan tingkat keberhasilan antar kelompok, tetapi data tidak menunjukkan bahwa semakin lama durasi campaign maka semakin rendah success rate.

## Dahsboard
<img width="1389" height="690" alt="image" src="https://github.com/user-attachments/assets/7ce94162-cfc0-4c9e-ad6b-8a8b9832a15e" />
<img width="1388" height="687" alt="image" src="https://github.com/user-attachments/assets/f3419e1d-4b4c-468b-b8cb-409b0871d0cf" />

Lihat Visualisasi di [Tableau](https://public.tableau.com/views/KickstarterCampaignSuccessAnalysis/RingkasanDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

## Insight
1. Kampanye dengan target pendanaan < $2.000 memiliki tingkat keberhasilan 52,9%, sedangkan target ≥ $50.000 hanya 15,0%. Semakin tinggi target pendanaan, semakin rendah tingkat keberhasilan yang terlihat pada dataset ini.
2. Keberhasilan kampanye sangat bervariasi antar kategori. Dance memiliki tingkat keberhasilan tertinggi (65,4%), sedangkan Technology terendah (23,8%). Ini menunjukkan bahwa kategori proyek memiliki pola keberhasilan yang berbeda dan tidak dapat disamakan antar kategori.
3. Banyaknya proyek tidak menjamin tingkat keberhasilan yang tinggi. Jumlah proyek mencapai puncaknya pada 2015 dengan 59.306 proyek, tetapi tingkat keberhasilan justru berada pada titik terendah (32,1%). Artinya, pertumbuhan jumlah kampanye tidak selalu diikuti peningkatan proporsi kampanye yang berhasil.
4. Durasi kampanye memiliki hubungan yang tidak linear dengan keberhasilan. kampanye <=15 hari memiliki tingkat keberhasilan 50%, sementara kampanye 46–60 hari hanya 27%, tetapi kampanye >60 hari kembali mencapai 39%. Jadi, memperpanjang durasi kampanye tidak otomatis meningkatkan atau menurunkan peluang keberhasilan.

## Rekomendasi
1. Kampanye dengan target lebih rendah menunjukkan tingkat keberhasilan yang lebih tinggi. Oleh karena itu, pembuat kampanye sebaiknya menetapkan target berdasarkan kebutuhan pendanaan yang realistis dan kemampuan kampanye dalam memperoleh dukungan, bukan menetapkan target terlalu tinggi.
2. Perbedaan tingkat keberhasilan antar kategori menunjukkan bahwa kategori proyek dapat menjadi salah satu pertimbangan dalam menyusun strategi kampanye. Kategori dengan tingkat keberhasilan rendah perlu melakukan evaluasi lebih lanjut terhadap target dan strategi menarik pendukung sebelum proyek kampanye diluncurkan.
3. Peningkatan jumlah proyek tidak selalu diikuti peningkatan success rate (tingkat keberhasilan). Evaluasi performa sebaiknya lebih berfokus pada proporsi kampanye yang berhasil, bukan hanya pada banyaknya campaign yang diluncurkan.
4. Data tidak menunjukkan hubungan linear antara durasi dan keberhasilan. Pembuat kampanye sebaiknya menentukan durasi berdasarkan karakteristik proyek dan strategi kampanye, bukan sekadar memperpanjang periode pendanaan dengan asumsi bahwa durasi lebih panjang akan meningkatkan keberhasilan.
   
## Tools
SQL (MySQL), Tableau Public
