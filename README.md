# Video Game Market Analysis
## Overview

This project was created as the **final project for CS50's Introduction to Databases with SQL (CS50 SQL)**.

It stores and analyses video game sales data from the VGChartz 2024 dataset available on [Kaggle](https://www.kaggle.com/datasets/asaniczka/video-game-sales-2024) obtained through Maven Analytics.
The CSV dataset contains box art image URLs, game titles, consoles, genres, publishers, developers, critic scores, total sales, regional sales, release dates, and last update dates.

To reduce redundancy and improve data integrity, the database is normalised into five related tables. Separate lookup tables are created to store consoles, genres, publishers, and developers, while the `games` table references them through foreign keys. The box art image column is dropped because it is not required for the analyses performed in this project.

Since the CSV file stores publisher, developer, genre, and console names as text values, these are replaced with their corresponding IDs after the data is imported to establish relationships with their respective lookup tables.

SQL views are also created to simplify common analytical queries.

**This project was built using MySQL 8.0 and MySQL Workbench.**

## Relationship Diagram

<img width="4442" height="1435" alt="game_relation_graph" src="https://github.com/user-attachments/assets/9aece6df-692b-4bef-bf2c-d02092c9c202" />

## Database Design

### games

Stores the primary information for every video game.

Column and Description
id - Unique identifier for each game (PK)
title - Name of the game
console_id - References the console (FK)
genre_id - References the genre (FK)
publisher_id - References the publisher (FK)
developer_id - References the developer (FK)
critic_score - Average critic score
total_sales - Global sales (millions)
na_sales - North American sales
jp_sales - Japanese sales
euro_african_sales - Europe & Africa sales
other_sales - Other regional sales
release_date - Original release date
last_update - Dataset update date

### consoles

Stores unique console names.

Column  Description
id - Console ID
console_name - Console name

### genres

Stores unique game genres.

Column and Description
id - Genre ID
game_genre - Genre name

### publishers

Stores unique publisher names.

Column and Description
id - Publisher ID
publisher_name - Publisher name

### developers

Stores unique developer names.

Column and Description
id - Developer ID
dev_name - Developer name

## Relationships

The database follows a one-to-many relationship structure.

- One console can have many games.
- One genre can contain many games.
- One publisher can publish many games.
- One developer can develop many games.

The `games` table references each lookup table using foreign keys.

## Normalization

The database is normalised to **Third Normal Form (3NF)**.

Instead of storing publisher, developer, genre, and console names repeatedly in every game record, each is stored once in its own table. The `games` table stores only their corresponding IDs.

This design:

- Reduces duplicate data
- Saves storage space
- Prevents update anomalies
- Improves consistency
- Makes sure foreign keys reference valid records

## Indexes

Indexes are created on all foreign key columns in the `games` table.
No additional indexes were created because query execution times were already satisfactory for the dataset size (approximately 64,000 records), and extra indexes would increase storage usage.

## Views

Three SQL views simplify common analytical queries.

### publisher_sales

Calculates the total sales for every publisher.

### developer_sales

Calculates the total sales for every developer.

### total_console_games

Returns the total number of games available for each console.

## Design Decisions

Several design choices were made during development.

- The dataset was normalised into five related tables to eliminate duplicated text values.
- Foreign keys maintain relationships between games and lookup tables.
- Views were created to avoid repeatedly writing complex aggregation queries.
- Games with zero sales are preserved because they represent titles with no recorded sales rather than missing records.
- Lookup tables improve consistency by storing each publisher, developer, genre, and console only once.

## Future Improvements

Possible extensions include:

- Adding a platform manufacturer table.
- Recording yearly sales instead of lifetime totals.
- Adding user ratings and review counts.
- Adding more information on publishers, developers, and consoles.

## Dataset

**Dataset:** VGChartz 2024 Video Game Sales Dataset

**Source:** Kaggle (provided by Maven Analytics)

The dataset contains approximately **64,000** video game records, including game titles, publishers, developers, genres, console platforms, critic scores, regional sales, and release dates.

## Limitations

The dataset contains many games with missing or unrecorded values, particularly for sales and critic scores. Additionally, over 46,000 games have zero recorded total sales, which likely represents unavailable sales information rather than actual zero sales. These limitations may affect the accuracy of certain analyses.

## Author

**Nikhil**
