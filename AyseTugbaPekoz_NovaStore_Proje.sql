-- ============================================
-- AYŞETUĞBAPEKÖZ_NovaStore_Proje.sql
-- NovaStore E-Ticaret Veri Yönetim Sistemi
-- ============================================

-- BÖLÜM 1: VERİ TABANI OLUŞTURMA


USE master;
GO

IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO


-- BÖLÜM 1: TABLOLARIN OLUŞTURULMASI

-- A. Categories Tablosu
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO

-- B. Customers Tablosu
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50),
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE
);
GO

-- C. Products Tablosu
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT DEFAULT 0,
    CategoryID INT,
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- D. Orders Tablosu
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- E. OrderDetails Tablosu
CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO


-- BÖLÜM 2: VERİ GİRİŞİ


-- Görev 1: 5 adet kategori ekleme
INSERT INTO Categories (CategoryName)
VALUES 
('Elektronik'),
('Giyim'),
('Kitap'),
('Kozmetik'),
('Ev ve Yaşam');
GO

-- Görev 2: 10-12 ürün ekleme
INSERT INTO Products (ProductName, Price, Stock, CategoryID)
VALUES
('Bluetooth Kulaklık', 899.99, 15, 1),
('Kablosuz Mouse', 349.50, 25, 1),
('Mekanik Klavye', 1250.00, 12, 1),
('Erkek Tişört', 299.99, 40, 2),
('Kadın Ceket', 849.90, 8, 2),
('SQL Öğreniyorum', 180.00, 30, 3),
('Veri Tabanı Sistemleri', 220.00, 18, 3),
('Yüz Temizleme Jeli', 145.50, 22, 4),
('Güneş Kremi', 210.75, 14, 4),
('Masa Lambası', 390.00, 10, 5),
('Dekoratif Yastık', 175.25, 28, 5),
('Duvar Saati', 260.00, 19, 5);
GO

-- Görev 3: 5-6 müşteri ekleme
INSERT INTO Customers (FullName, City, Email)
VALUES
('Ahmet Yılmaz', 'İstanbul', 'ahmetyilmaz@gmail.com'),
('Ayşe Demir', 'Ankara', 'aysedemir@gmail.com'),
('Mehmet Kaya', 'İzmir', 'mehmetkaya@gmail.com'),
('Zeynep Arslan', 'Bursa', 'zeynepars@gmail.com'),
('Can Polat', 'Antalya', 'canpolat@gmail.com'),
('Elif Şahin', 'Adana', 'elifsahin@gmail.com');
GO

-- Görev 4: 8-10 sipariş ekleme
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
(1, '2026-04-01', 1249.49),
(2, '2026-04-03', 1149.89),
(3, '2026-04-05', 400.00),
(1, '2026-04-06', 210.75),
(4, '2026-04-08', 565.25),
(5, '2026-04-10', 899.99),
(6, '2026-04-11', 740.00),
(2, '2026-04-12', 299.99),
(3, '2026-04-13', 145.50),
(4, '2026-04-15', 1510.00);
GO

-- Sipariş detayları ekleme
INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES
(1, 1, 1),
(1, 2, 1),
(2, 5, 1),
(2, 8, 2),
(3, 6, 1),
(3, 7, 1),
(4, 9, 1),
(5, 10, 1),
(5, 11, 1),
(6, 1, 1),
(7, 12, 2),
(7, 6, 1),
(8, 4, 1),
(9, 8, 1),
(10, 3, 1),
(10, 10, 1);
GO

-- BÖLÜM 3: SORGULAMA VE ANALİZ

-- Soru 1: Stok miktarı 20'den az olan ürünler
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

-- Soru 2: Hangi müşteri, hangi tarihte sipariş vermiş
SELECT 
    c.FullName AS MusteriAdi,
    c.City AS Sehir,
    o.OrderDate AS SiparisTarihi,
    o.TotalAmount AS ToplamTutar
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID;
GO

-- Soru 3: Ahmet Yılmaz'ın aldığı ürünler, fiyatları ve kategorileri
SELECT 
    c.FullName AS MusteriAdi,
    p.ProductName AS UrunAdi,
    p.Price AS Fiyat,
    cat.CategoryName AS Kategori
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od
    ON o.OrderID = od.OrderID
INNER JOIN Products p
    ON od.ProductID = p.ProductID
INNER JOIN Categories cat
    ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz';
GO

-- Soru 4: Hangi kategoride toplam kaç adet ürün var
SELECT 
    cat.CategoryName AS KategoriAdi,
    COUNT(p.ProductID) AS UrunSayisi
FROM Categories cat
LEFT JOIN Products p
    ON cat.CategoryID = p.CategoryID
GROUP BY cat.CategoryName;
GO

-- Soru 5: Her müşterinin şirkete kazandırdığı toplam ciro
SELECT 
    c.FullName AS MusteriAdi,
    SUM(o.TotalAmount) AS ToplamHarcama
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.FullName
ORDER BY ToplamHarcama DESC;
GO

-- Soru 6: Siparişlerin üzerinden kaç gün geçtiği
SELECT 
    OrderID,
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGun
FROM Orders;
GO

-- BÖLÜM 4: İLERİ SEVİYE VERİ TABANI NESNELERİ-- ============================================

-- 1. View Oluşturma
CREATE VIEW vw_SiparisOzet
AS
SELECT
    c.FullName AS MusteriAdi,
    o.OrderDate AS SiparisTarihi,
    p.ProductName AS UrunAdi,
    od.Quantity AS Adet
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od
    ON o.OrderID = od.OrderID
INNER JOIN Products p
    ON od.ProductID = p.ProductID;
GO

-- View kontrol sorgusu
SELECT * FROM vw_SiparisOzet;
GO

-- 2. Yedekleme Komutu
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH FORMAT,
     MEDIANAME = 'NovaStoreBackup',
     NAME = 'NovaStoreDB Full Backup';
GO