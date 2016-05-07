#!/usr/bin/env perl
use Domino::Irc::Bot;

my $nickname = 'example';
my $ircname  = 'example';
my $server   = 'irc.twitch.tv';
my $port = 6667;
my $pass = 'oauth:#########################';

my $bot = Domino::Irc::Bot->new(
    server => $server,
    port   => $port,
    channels => ["#".$ircname],
    password => $pass,
    
    nick      => $nickname,
    username  => $ircname,
    name      => $ircname,

    );

$bot->initCommands;
$bot->initGame(
{
    max_domino_value => 6,
    num_players => 4,
#    max_domino_value => 9,
#    num_players => 4,
    game_points_limit => 10,
    player_types => [
	'Bot',
	'Bot',
	'Bot',
	'Bot',
    ],
});

$bot->run();

