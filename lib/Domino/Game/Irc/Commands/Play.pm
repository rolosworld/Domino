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
package Domino::Game::Irc::Commands::Play;
use Modern::Perl;

use parent 'Domino::Game::Irc::Commands';

sub parse {
    my ($self, $type, $domino_move) = @_;
    delete $$self{command};

    if ($domino_move) {
	my $direction = substr( $domino_move, 0, 1 );
	return undef if $direction ne '>' && $direction ne '<';
	$direction = $direction eq '<' ? 0 : 1;

	my $domino = substr( $domino_move, 1 ) - 1;
	return undef if $domino < 0;

	$$self{command} = {
	    type      => $type,
	    direction => $direction,
	    domino    => $domino,
	};
	return $self;
    }

    return undef;
}

sub run {
    my ($self, $ctx, $args) = @_;
    my $command = $$self{command};
    my $game = $$ctx{game};
    my $table = $$game{table};
    my $players_count = $table->getPlayersCount;

    # !play ...
    #   Check if game in progress
    if ($players_count == $$game{num_players}) {

	#   Check player exist
	my $player = $$table{players_map}{$$args{who}};
	if ($player) {

	    #   Check if is player turn
	    if ($$table{current_player} == $$player{id}) {

		# Validate play
		$$command{player} = $player;
		my $results = $game->run( $args, $command );
		return $results;
	    }

	    $$args{body} = sprintf( "Waiting for %s to make a move", $$table{players}[$$table{current_player}]{name} );
	}
    }
    else {
	$$args{body} = 'Waiting for more players';
    }

    return [$args];
}

1;
