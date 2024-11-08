-- Ensure the pgcrypto extension is enabled for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create `crypto_games` table
CREATE TABLE crypto_games (
    game_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_name VARCHAR(100) NOT NULL,
    start_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    end_time TIMESTAMP WITHOUT TIME ZONE,
    status VARCHAR(50) NOT NULL
);

-- Index on `game_name` to speed up queries by game name
CREATE INDEX idx_game_name ON crypto_games (game_name);

-- Index on `status` to speed up status-based queries
CREATE INDEX idx_game_status ON crypto_games (status);

-- Create `crypto_game_tickets` table
CREATE TABLE crypto_game_tickets (
    ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL,
    purchase_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    player_id UUID NOT NULL,
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL,
    prize_amount NUMERIC,
    FOREIGN KEY (game_id) REFERENCES crypto_games (game_id) ON DELETE CASCADE
);

-- Index on `game_id` for faster joins and lookups by game
CREATE INDEX idx_ticket_game_id ON crypto_game_tickets (game_id);

-- Index on `player_id` for faster joins and lookups by player
CREATE INDEX idx_ticket_player_id ON crypto_game_tickets (player_id);

-- Create `crypto_game_players` table
CREATE TABLE crypto_game_players (
    player_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index on `player_name` to speed up searches by player name
CREATE INDEX idx_player_name ON crypto_game_players (player_name);

-- Create `crypto_game_player_rankings` table
CREATE TABLE crypto_game_player_rankings (
    ranking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    game_id UUID NOT NULL,
    ranking INTEGER NOT NULL,
    points NUMERIC,
    FOREIGN KEY (player_id) REFERENCES crypto_game_players (player_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES crypto_games (game_id) ON DELETE CASCADE
);

-- Index on `player_id` to speed up joins and lookups by player in rankings
CREATE INDEX idx_ranking_player_id ON crypto_game_player_rankings (player_id);

-- Index on `game_id` for faster joins with games in the rankings table
CREATE INDEX idx_ranking_game_id ON crypto_game_player_rankings (game_id);




-- Insert a game into `crypto_games`
INSERT INTO crypto_games (game_name, start_time, end_time, status)
VALUES ('Poker Train', '2024-11-01 10:00:00', '2024-11-01 22:00:00', 'active');

-- Insert a player into `crypto_game_players`
INSERT INTO crypto_game_players (player_name, email, join_date)
VALUES ('Count Dracula', 'countdracula@transylvanians.com', '2024-11-01 09:30:00');

-- Insert a ticket for the game and player into `crypto_game_tickets`
INSERT INTO crypto_game_tickets (game_id, purchase_time, player_id, ticket_number, status, prize_amount)
VALUES (
    (SELECT game_id FROM eql_games WHERE game_name = 'Poker Train'),  -- Linking to the created game
    '2024-11-01 10:15:00',
    (SELECT player_id FROM eql_game_players WHERE player_name = 'Count Dracula'),  -- Linking to the created player
    'TICKET12345',
    'pending',
    100.50
);

-- Insert a ranking for the player in the game into `crypto_game_player_rankings`
INSERT INTO crypto_game_player_rankings (player_id, game_id, ranking, points)
VALUES (
    (SELECT player_id FROM crypto_game_players WHERE player_name = 'Count Dracula'),
    (SELECT game_id FROM crypto_games WHERE game_name = 'Poker Train'),
    1,
    1500
);



