-- MySQL dump 10.11
--
-- Host: localhost    Database: buy
-- ------------------------------------------------------
-- Server version	5.0.51b-community-nt

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `brand`
--

DROP TABLE IF EXISTS `brand`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `brand` (
  `ID` int(11) unsigned NOT NULL auto_increment COMMENT '自增',
  `Name` varchar(255) NOT NULL default '' COMMENT '品牌中文名',
  `EngName` varchar(255) NOT NULL default '' COMMENT 'English Name',
  `SiteURL` varchar(255) NOT NULL default '' COMMENT '品牌官方网址',
  `Alias` varchar(255) NOT NULL default '' COMMENT 'separated by ||',
  `DefaultVisuality` enum('LOGO','NORMAL TEXT','BOLD TEXT') NOT NULL default 'NORMAL TEXT',
  `DefaultTextUnderLogo` varchar(255) NOT NULL default '' COMMENT '品牌logo下的说明文字',
  `DefaultSalesMessage` text COMMENT '品牌销售说明',
  `LogoFile` varchar(255) NOT NULL default '' COMMENT 'logo的路径',
  `LogoWidth` smallint(5) unsigned NOT NULL default '0' COMMENT 'logo宽度',
  `LogoHeight` smallint(5) unsigned NOT NULL default '0' COMMENT 'logo高度',
  `Type` enum('Brand','Manufacturer') NOT NULL default 'Manufacturer' COMMENT '品牌类型（商店，品牌）',
  `Description` varchar(255) NOT NULL default '' COMMENT '描述',
  `r_OnlineProductCount` int(11) unsigned NOT NULL default '0' COMMENT '线上产品数',
  `r_TotalProductCount` int(11) unsigned NOT NULL default '0' COMMENT '总共产品数',
  `r_Popularity` int(11) unsigned NOT NULL default '0' COMMENT '受欢迎度',
  `AddDate` timestamp NOT NULL default '2000-01-01 00:00:00' COMMENT '增加时间',
  `IsApproved` enum('YES','NO') NOT NULL default 'NO' COMMENT '是否已经通过',
  `ApprovedBy` varchar(50) NOT NULL default '',
  `IsDelete` enum('YES','NO') NOT NULL default 'NO',
  `DeletedBy` varchar(50) NOT NULL default '',
  `IsSEOModify` enum('YES','NO') NOT NULL default 'NO',
  `BrandSEOName` varchar(255) NOT NULL default '',
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `isBMV` enum('YES','NO') NOT NULL default 'NO',
  `URLName` varchar(255) NOT NULL default '',
  `LastEditor` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `brand`
--

LOCK TABLES `brand` WRITE;
/*!40000 ALTER TABLE `brand` DISABLE KEYS */;
/*!40000 ALTER TABLE `brand` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c3category`
--

DROP TABLE IF EXISTS `c3category`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `c3category` (
  `id` int(11) NOT NULL auto_increment COMMENT '★',
  `CategoryID` int(11) unsigned NOT NULL COMMENT '★CategoryID',
  `Name` varchar(128) NOT NULL default '' COMMENT '★Category Name',
  `EngName` varchar(128) default '' COMMENT '★Category English Name',
  `Alias` varchar(128) NOT NULL default '' COMMENT '?',
  `SEAlias` text COMMENT 'Search alias?',
  `Type` enum('Normal','BMV','FreeText','Structured','Special') NOT NULL default 'Normal' COMMENT '★',
  `Description` text COMMENT '★Category description',
  `IsPublic` enum('YES','NO') NOT NULL default 'YES' COMMENT 'If the category is public',
  `IsActive` enum('YES','NO') NOT NULL default 'YES' COMMENT '★If the category is avtive',
  `IsValid` enum('YES','NO') NOT NULL default 'YES' COMMENT '★If the category is valid',
  `externalURL` varchar(512) NOT NULL default '',
  `r_OnlineProductCount` int(11) unsigned NOT NULL default '0' COMMENT '★',
  `r_CPCOnlineProductCount` int(11) unsigned NOT NULL default '0',
  `r_TotalProductCount` int(11) unsigned NOT NULL default '0' COMMENT '★',
  `r_CPCTotalProductCount` int(11) unsigned NOT NULL default '0',
  `r_Popularity` int(11) unsigned NOT NULL default '0' COMMENT '★',
  `AddDate` timestamp NULL default NULL COMMENT '★',
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT '★',
  `URLName` varchar(255) NOT NULL default '' COMMENT '★',
  `LeftNavName` varchar(255) NOT NULL default '',
  `SearchName` varchar(255) NOT NULL default '' COMMENT '★',
  `SingularName` varchar(128) NOT NULL default '' COMMENT '★单数的',
  `PluralName` varchar(255) NOT NULL default '' COMMENT '★复数的',
  `SingularSynonym1` varchar(255) NOT NULL default '',
  `PluralSynonym1` varchar(255) NOT NULL default '',
  `CategorySEOtext` varchar(255) NOT NULL default '',
  `SingularSynonym2` varchar(255) NOT NULL default '',
  `SingularSynonym3` varchar(255) NOT NULL default '',
  `PluralSynonym2` varchar(255) NOT NULL default '',
  `PluralSynonym3` varchar(255) NOT NULL default '',
  `IsSEOModify` enum('YES','NO') NOT NULL default 'NO',
  `r_KeywordRevenue` decimal(10,4) NOT NULL default '0.0000',
  PRIMARY KEY  (`id`,`CategoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `c3category`
--

LOCK TABLES `c3category` WRITE;
/*!40000 ALTER TABLE `c3category` DISABLE KEYS */;
/*!40000 ALTER TABLE `c3category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c3merchantbidproduct`
--

DROP TABLE IF EXISTS `c3merchantbidproduct`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `c3merchantbidproduct` (
  `OfferID` int(11) unsigned NOT NULL default '0',
  `MerchantID` int(11) unsigned NOT NULL default '0',
  `ProductID` int(11) unsigned NOT NULL default '0',
  `UniquePID` int(11) unsigned NOT NULL default '0',
  `ProductName` varchar(255) NOT NULL default '',
  `ProductSKU` varchar(255) NOT NULL default '',
  `BrandName` varchar(255) NOT NULL default '',
  `ProductDescription` text,
  `CategoryName` text,
  `ShippingCostFix` decimal(11,2) NOT NULL default '0.00',
  `Price` decimal(11,2) NOT NULL default '0.00',
  `ListPrice` decimal(11,2) NOT NULL default '0.00',
  `CurrencySymbol` char(3) NOT NULL default '' COMMENT 'Abbr of currency.',
  `URL` text,
  `ImageURL` text,
  `DisplayLogo` enum('YES','NO','FREE') NOT NULL default 'NO' COMMENT 'corresponding to r_LogoCPC',
  `StockStatus` enum('In Stock','Out Of Stock','Special Order','Pre Order','Unknown') NOT NULL default 'Unknown',
  `PriceStatus` enum('WLINK','WOLINK') NOT NULL default 'WLINK',
  `SpecialOffer` varchar(1000) NOT NULL default '',
  `ProductCondition` varchar(255) NOT NULL default '',
  `MerRank` char(33) NOT NULL default '000000000000000000000000000000000',
  `r_Coupon` smallint(5) NOT NULL default '0',
  `r_CPC` decimal(5,2) NOT NULL default '0.00',
  `r_CPCCurrency` char(3) NOT NULL default '' COMMENT 'Abbr of currency.',
  `r_ExtraCPC` decimal(5,2) NOT NULL default '0.00',
  `r_LogoCPC` decimal(5,2) NOT NULL default '0.00',
  `r_BusinessType` enum('CPC','CPA','CPC-H','FREE') NOT NULL default 'CPC',
  `AddDate` timestamp NULL default NULL,
  `MerchantSKU` varchar(255) NOT NULL default '',
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `Position` int(11) NOT NULL default '0',
  `r_CategoryID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`OfferID`),
  UNIQUE KEY `MerchantProduct` (`MerchantID`,`ProductID`),
  KEY `ProductID` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `c3merchantbidproduct`
--

LOCK TABLES `c3merchantbidproduct` WRITE;
/*!40000 ALTER TABLE `c3merchantbidproduct` DISABLE KEYS */;
/*!40000 ALTER TABLE `c3merchantbidproduct` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c3product`
--

DROP TABLE IF EXISTS `c3product`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `c3product` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `ProductID` int(11) unsigned NOT NULL default '0' COMMENT 'ProductID',
  `UniquePID` int(11) unsigned NOT NULL default '0' COMMENT 'Global Product ID',
  `Name` varchar(500) NOT NULL default '' COMMENT 'Product Name',
  `EngName` varchar(400) default '' COMMENT 'Product English Name',
  `BrandID` int(11) NOT NULL default '0',
  `BrandName` varchar(255) NOT NULL default '',
  `HasImage` enum('YES','NO') NOT NULL default 'NO' COMMENT 'If it has image',
  `Brief` varchar(500) default '' COMMENT 'Brief',
  `Description` text COMMENT 'description',
  `AddDate` timestamp NULL default NULL COMMENT 'Add date',
  `r_Popularity` int(11) unsigned NOT NULL default '0' COMMENT 'Product popularity',
  `r_Spec` enum('YES','NO') NOT NULL default 'NO' COMMENT 'If the product has spec',
  `r_AvgRating` decimal(5,2) NOT NULL default '0.00',
  `r_ImageCount` smallint(5) NOT NULL default '0',
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`,`ProductID`),
  UNIQUE KEY `UniquePID` (`UniquePID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `c3product`
--

LOCK TABLES `c3product` WRITE;
/*!40000 ALTER TABLE `c3product` DISABLE KEYS */;
/*!40000 ALTER TABLE `c3product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c3productcategory`
--

DROP TABLE IF EXISTS `c3productcategory`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `c3productcategory` (
  `ID` int(11) unsigned NOT NULL auto_increment,
  `ProductID` int(11) unsigned NOT NULL default '0',
  `CategoryID` int(11) unsigned NOT NULL default '0',
  `AddDate` timestamp NULL default NULL,
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ID`,`ProductID`),
  KEY `CategoryID` (`CategoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `c3productcategory`
--

LOCK TABLES `c3productcategory` WRITE;
/*!40000 ALTER TABLE `c3productcategory` DISABLE KEYS */;
/*!40000 ALTER TABLE `c3productcategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c3productextendinfo`
--

DROP TABLE IF EXISTS `c3productextendinfo`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `c3productextendinfo` (
  `ID` int(11) unsigned NOT NULL auto_increment,
  `ProductID` int(11) unsigned NOT NULL default '0',
  `Info` text,
  `InfoType` varchar(50) default NULL,
  `AddDate` timestamp NULL default NULL,
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ID`),
  KEY `ProductID` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `c3productextendinfo`
--

LOCK TABLES `c3productextendinfo` WRITE;
/*!40000 ALTER TABLE `c3productextendinfo` DISABLE KEYS */;
/*!40000 ALTER TABLE `c3productextendinfo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c3productimage`
--

DROP TABLE IF EXISTS `c3productimage`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `c3productimage` (
  `ID` int(11) unsigned NOT NULL auto_increment,
  `ImageID` int(11) unsigned NOT NULL default '0' COMMENT 'Product ImageID',
  `ProductID` int(11) unsigned NOT NULL default '0' COMMENT 'ProductID',
  `ImageWidth` smallint(5) unsigned NOT NULL default '0',
  `ImageHeight` smallint(5) unsigned NOT NULL default '0',
  `Sequence` smallint(5) unsigned NOT NULL default '0' COMMENT 'Product Image Sequence',
  `ImageFileSize` int(11) unsigned NOT NULL default '0' COMMENT 'Product Image File size',
  `ImageFileMD5` char(32) NOT NULL default '' COMMENT 'MD5 value for this images',
  `IsMain` enum('YES','NO') NOT NULL default 'NO' COMMENT 'If the picture is treated as the main it',
  `AddDate` timestamp NULL default NULL,
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ID`),
  UNIQUE KEY `UK_ProdID_ImgID` (`ProductID`,`ImageID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `c3productimage`
--

LOCK TABLES `c3productimage` WRITE;
/*!40000 ALTER TABLE `c3productimage` DISABLE KEYS */;
/*!40000 ALTER TABLE `c3productimage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c3productskus`
--

DROP TABLE IF EXISTS `c3productskus`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `c3productskus` (
  `ID` int(11) unsigned NOT NULL auto_increment,
  `ProductID` int(11) unsigned NOT NULL default '0',
  `ProductNO` varchar(255) NOT NULL default '',
  `Type` enum('EAN','ISBN','UPC','SKU','MfPN','CatalogNo','MerchantUniqueCode','ASIN','SDCN','Unknown') NOT NULL default 'Unknown',
  `IsMain` enum('YES','NO') NOT NULL default 'NO',
  `Comments` varchar(255) NOT NULL default '',
  `AddDate` timestamp NULL default NULL,
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ID`),
  KEY `ProductID` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `c3productskus`
--

LOCK TABLES `c3productskus` WRITE;
/*!40000 ALTER TABLE `c3productskus` DISABLE KEYS */;
/*!40000 ALTER TABLE `c3productskus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channel`
--

DROP TABLE IF EXISTS `channel`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `channel` (
  `ID` int(11) unsigned NOT NULL auto_increment,
  `Name` varchar(100) NOT NULL default '',
  `EngName` varchar(100) NOT NULL default '',
  `Host` varchar(100) NOT NULL default '',
  `DB` varchar(100) NOT NULL default '',
  `ProductTable` varchar(64) NOT NULL default '',
  `ProductSKUTable` varchar(64) NOT NULL default '',
  `ProductSkipTable` varchar(64) NOT NULL,
  `ProductImageTable` varchar(64) NOT NULL default '',
  `ProductPriceTable` varchar(64) NOT NULL default '',
  `ProductExtendInfoTable` varchar(64) NOT NULL default '',
  `CategoryTable` varchar(64) NOT NULL default '',
  `CatProdTable` varchar(64) NOT NULL default '',
  `MerBidProdTable` varchar(64) NOT NULL default '',
  `CategoryAttributeFilterTable` varchar(64) NOT NULL default '',
  `CategoryAttributeSpecTable` varchar(64) NOT NULL default '',
  `ProductAttributeFilterTable` varchar(64) NOT NULL default '',
  `ProductAttributeSpecTable` varchar(64) NOT NULL default '',
  `Type` varchar(10) NOT NULL default '',
  `IsValid` enum('YES','TEST','NO') NOT NULL default 'NO',
  `ChannelGroup` enum('BMV','CE','SG') NOT NULL default 'SG',
  `DatafeedChnID` tinyint(3) NOT NULL default '0',
  `SEODisplayName` varchar(32) default NULL,
  `URLName` varchar(32) default NULL,
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `channel`
--

LOCK TABLES `channel` WRITE;
/*!40000 ALTER TABLE `channel` DISABLE KEYS */;
/*!40000 ALTER TABLE `channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant`
--

DROP TABLE IF EXISTS `merchant`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `merchant` (
  `id` int(11) NOT NULL auto_increment,
  `MerchantID` int(11) unsigned NOT NULL default '0',
  `MerchantName` varchar(100) NOT NULL default '',
  `NameAlias` varchar(500) NOT NULL default '' COMMENT 'Separated by ||',
  `Country` char(3) NOT NULL default '',
  `SiteURL` varchar(255) NOT NULL default '',
  `SiteLink` enum('YES','NO','PARTIAL') NOT NULL default 'NO',
  `PartnerSource` varchar(255) NOT NULL default '' COMMENT 'used for group merchant, some merchant in Smarter is registed from 3rd partner source, use this field to mark the parnter name',
  `StoreLocType` enum('ECS','OSS','BOTH') NOT NULL default 'BOTH' COMMENT 'ECS: E-Commerce Store, OSS: On-Street Store, Both- have both store ',
  `RegisterDate` datetime NOT NULL default '2000-01-01 00:00:00',
  `SalesMessage` varchar(2000) NOT NULL default '',
  `Authorized` enum('YES','NO') NOT NULL default 'NO',
  `MerSource` enum('OWN','PARNTER','BOTH') NOT NULL default 'OWN',
  `ROIService` enum('Advance','Basic','NO') NOT NULL default 'NO',
  `CCReviewService` enum('YES','NO') NOT NULL default 'NO',
  `ShowCCReview` enum('YES','NO') NOT NULL default 'NO',
  `IsTrusted` enum('YES','NO') NOT NULL default 'NO',
  `PriceStatus` enum('WLINK','WOLINK','OFFLINE') NOT NULL default 'WOLINK' COMMENT 'W-with, WO-without',
  `PriceShare` enum('LOCAL','INTERNATIONALWLINK','INTERNATIONALWOLINK') NOT NULL default 'LOCAL' COMMENT 'LOCAL means only local country can display offer, International means accross country can display offers, WLink means with Link, WOLink means without Link',
  `MerTier` enum('Platinum','Gold','Silver','Lead') NOT NULL default 'Silver',
  `Featured` enum('YES','NO') NOT NULL default 'NO',
  `FeaturedCPC` decimal(5,2) NOT NULL default '0.00',
  `FEBlockSwitch` enum('OFF','ON') NOT NULL default 'OFF',
  `DatafeedSwitch` enum('OFF','ON') NOT NULL default 'ON',
  `BusinessType` enum('CPC','CPA','FREE','CPC-H') NOT NULL default 'CPC' COMMENT 'check MerDeal table',
  `MerLogoDisplay` enum('YES','NO') NOT NULL default 'NO',
  `DefaultCPC` decimal(5,2) NOT NULL default '0.00',
  `AffiliateName` varchar(20) NOT NULL default '',
  `AffiliateKey` varchar(10) NOT NULL default '',
  `LastChangeDate` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `r_ReviewCount` int(11) NOT NULL default '0',
  `r_AvgRating` decimal(5,2) NOT NULL default '0.00',
  `r_OwnTotalOfferCount` int(11) unsigned NOT NULL default '0',
  `r_OwnOnlineOfferCount` int(11) unsigned NOT NULL default '0',
  `r_PartnerTotalOfferCount` int(11) unsigned NOT NULL default '0',
  `r_PartnerOnlineOfferCount` int(11) unsigned NOT NULL default '0',
  `r_Popularity` int(11) unsigned NOT NULL default '0',
  `r_ProductCount` int(11) unsigned NOT NULL default '0',
  `r_ImpressionCount` int(11) unsigned NOT NULL default '0',
  `r_ClickCount` int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`,`MerchantID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `merchant`
--

LOCK TABLES `merchant` WRITE;
/*!40000 ALTER TABLE `merchant` DISABLE KEYS */;
/*!40000 ALTER TABLE `merchant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productreview`
--

DROP TABLE IF EXISTS `productreview`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `productreview` (
  `ID` int(11) NOT NULL default '0',
  `ChannelID` int(11) NOT NULL default '0',
  `ProductID` int(11) NOT NULL default '0',
  `ReviewTime` datetime NOT NULL default '0000-00-00 00:00:00',
  `IsReview` enum('NO','YES') NOT NULL default 'NO',
  `ReviewTitle` varchar(255) NOT NULL default '',
  `ReviewText` text NOT NULL,
  `DisplayName` varchar(100) default 'N/A',
  `ScoreOverall` float(11,2) NOT NULL default '0.00',
  `ScoreQuality` float(11,2) NOT NULL default '0.00',
  `ScoreFeatures` float(11,2) NOT NULL default '0.00',
  `ScoreSupport` float(11,2) NOT NULL default '0.00',
  `ScoreValue` float(11,2) NOT NULL default '0.00',
  `HelpfulYesCount` int(11) NOT NULL default '0',
  `HelpfulNoCount` int(11) NOT NULL default '0',
  `IsApproved` enum('NO','YES') NOT NULL default 'NO',
  `ReportedAbuseCount` int(11) NOT NULL default '0',
  `ExpertID` int(11) NOT NULL default '0',
  `URL` text NOT NULL,
  `CDSID` int(11) NOT NULL default '0',
  `UserID` int(11) NOT NULL default '0',
  `r_CommentCount` int(11) default '0',
  `r_UserBlogCount` int(11) default '0',
  `r_ProductName` varchar(255) default NULL,
  `Location` varchar(200) default '',
  `ThirdPartReviewID` varchar(200) default '',
  `Pros` varchar(255) default '',
  `Cons` varchar(255) default '',
  `OwnedTime` varchar(30) default '',
  `LastChangeDate` timestamp NULL default NULL on update CURRENT_TIMESTAMP COMMENT 'log the last update datetime',
  PRIMARY KEY  (`ID`),
  KEY `ProductID` (`ProductID`),
  KEY `CDSID` (`CDSID`),
  KEY `ExpertID` (`ExpertID`),
  KEY `idx_ch_prod_PR` (`ChannelID`,`ProductID`),
  KEY `UserID` (`UserID`),
  KEY `idx_ch` (`ChannelID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 MAX_ROWS=4000000000;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `productreview`
--

LOCK TABLES `productreview` WRITE;
/*!40000 ALTER TABLE `productreview` DISABLE KEYS */;
/*!40000 ALTER TABLE `productreview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `user` (
  `UserID` int(11) NOT NULL auto_increment,
  `UserName` varchar(32) character set latin1 collate latin1_bin default NULL,
  `password` varchar(32) character set latin1 collate latin1_bin NOT NULL default '',
  `Email` varchar(64) NOT NULL,
  `Birthday` date NOT NULL default '0000-00-00',
  `Question` text,
  `Answer` text,
  `Validate` enum('YES','NO') default 'NO',
  `VisitTime` datetime default '0000-00-00 00:00:00',
  `Country` char(2) NOT NULL,
  `PostalCode` varchar(8) NOT NULL,
  `UserPaidAccount` varchar(64) NOT NULL,
  `AccountType` smallint(4) NOT NULL default '0',
  PRIMARY KEY  (`UserID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `login` (`UserName`,`password`)
) ENGINE=MyISAM AUTO_INCREMENT=32871 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-04-30 15:59:48
