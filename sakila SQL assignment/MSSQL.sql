/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [actor_id]
      ,[first_name]
      ,[last_name]
  FROM [sakila].[dbo].[actor]