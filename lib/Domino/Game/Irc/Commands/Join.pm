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
package Domino::Game::Irc::Commands::Join;
use Modern::Perl;

use parent 'Domino::Game::Irc::Commands';

sub run {
    my ($self, $ctx, $args) = @_;
    my $game = $$ctx{game};
    my $table = $$game{table};
    my $players_count = $table->getPlayersCount;
    my $results;

    if ($players_count < $$game{num_players}) {
	if ($$table{players_map}{$$args{who}}) {
	    $$args{body} = 'You are already playing';
	    return [$args]
	}

	$results = $game->sitPlayer( 'Irc', $$args{who}, $args );

	if ($players_count + 1 == $$game{num_players}) {
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
	}
    }

    return $results;
}

1;
