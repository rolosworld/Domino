###
# Copyright (c) 2016 Rolando González Chévere <rolosworld@gmail.com>
#
# This file is part of Domino.
#
# Domino is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3
# as published by the Free Software Foundation.
#
# Domino is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Meta.  If not, see <http://www.gnu.org/licenses/>.
####
package Domino::Game::Irc::Commands::Bots;
use Modern::Perl;

use parent 'Domino::Game::Irc::Commands';

sub run {
    my ($self, $ctx, $args) = @_;
    my $game = $$ctx{game};
    my $table = $$game{table};
    my $results;

    return undef if $table->getPlayersCount == $$game{num_players};

    while ($table->getPlayersCount < $$game{num_players}) {
	my $name;
	my $i = 0;
	do {
	    $name = sprintf("%s%d", 'BOT', $i++ );
	} while ($$table{players_map}{$name});

	push( @$results, @{$game->sitPlayer( 'Bot', $name, $args )} );
    }

    $game->prepareNewRound;
    my $players = $$table{players};
    foreach my $_player (@$players) {
	push( @$results, {
	    who     => $$_player{name},
	    channel => 'msg',
	    body    => sprintf("%s", $game->playerDominosStr($$_player{dominos}))
	});
    }
    push( @$results, {
	channel => $$args{channel},
	body    => sprintf( "Game started, %s turn", $$players[$table->getCurrentPlayer]{name} )
    });

    return $results;
}

1;
