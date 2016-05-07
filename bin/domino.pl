#!/usr/bin/env perl
use Domino::Game::Terminal;

$DB::single = 1;
my $game = Domino::Game::Terminal->new(
{
    max_domino_value => 6,
    num_players => 4,
#    max_domino_value => 9,
#    num_players => 4,
    game_points_limit => 100,
    player_types => [
#	'Terminal',
#	'Terminal',
#	'Terminal',
#	'Terminal',
	'Bot',
	'Bot',
	'Bot',
	'Bot',
    ],
});
$game->run;
