-- Membuat atau mengganti tabel kimia_farma.tabel_analisa
CREATE OR REPLACE TABLE kimia_farma.tabel_analisa AS  

-- Memilih kolom yang dibutuhkan dari tabel transaksi (t)
SELECT
  t.transaction_id, -- Kode unik transaksi  
  t.date, -- Tanggal transaksi  
  t.branch_id, -- ID cabang tempat transaksi dilakukan  

  kc.branch_name, -- Nama cabang berdasarkan branch_id  
  kc.kota, -- Kota cabang  
  kc.provinsi, -- Provinsi cabang  
  kc.rating_cabang, -- Rating cabang berdasarkan ulasan pelanggan  

  t.customer_name, -- Nama customer yang melakukan transaksi  
  t.product_id, -- Kode produk yang dibeli  
  p.product_name, -- Nama produk berdasarkan product_id  

  t.actual_price, -- Harga asli produk sebelum diskon  
  t.discount_percentage, -- Persentase diskon yang diberikan  

-- Menghitung persentase laba kotor (gross laba) berdasarkan ketentuan harga
  CASE  
    WHEN t.actual_price <= 50000 THEN 0.10 -- Harga <= Rp 50.000, laba 10%  
    WHEN t.actual_price > 50000 AND t.actual_price <= 100000 THEN 0.15 -- Harga Rp 50.001 - Rp 100.000, laba 15%  
    WHEN t.actual_price > 100000 AND t.actual_price <= 300000 THEN 0.20 -- Harga Rp 100.001 - Rp 300.000, laba 20%  
    WHEN t.actual_price > 300000 AND t.actual_price <= 500000 THEN 0.25 -- Harga Rp 300.001 - Rp 500.000, laba 25%  
    ELSE 0.30 -- Harga di atas Rp 500.000, laba 30%  
  END AS persentase_gross_laba,  

-- Menghitung nett_sales (Harga setelah diskon)  
  (t.actual_price - (t.actual_price * t.discount_percentage)) AS nett_sales,  

-- Menghitung nett_profit (Keuntungan bersih)  
  ((t.actual_price - (t.actual_price * t.discount_percentage)) *  
    CASE  
      WHEN t.actual_price <= 50000 THEN 0.10  
      WHEN t.actual_price > 50000 AND t.actual_price <= 100000 THEN 0.15  
      WHEN t.actual_price > 100000 AND t.actual_price <= 300000 THEN 0.20  
      WHEN t.actual_price > 300000 AND t.actual_price <= 500000 THEN 0.25  
      ELSE 0.30  
    END) AS nett_profit,  

  t.rating_transaksi -- Rating transaksi yang diberikan oleh pelanggan  
FROM  
  `kimia_farma.kf_final_transaction` t -- Tabel transaksi sebagai tabel utama  

-- Menggabungkan data cabang berdasarkan branch_id  
JOIN  
  `kimia_farma.kf_kantor_cabang` kc ON t.branch_id = kc.branch_id  

-- Menggabungkan data produk berdasarkan product_id  
JOIN  
  `kimia_farma.kf_product` p ON t.product_id = p.product_id; 