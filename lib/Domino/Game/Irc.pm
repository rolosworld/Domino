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
package Domino::Game::Irc;
use Modern::Perl;

use parent 'Domino::Game';

sub gameStep {
    my ($self, $table, $args, $command) = @_;
    my $results = [];
    my $player = $$command{player};
    my $play = $player->getPlay( $table, $command );
    if ($play) {
	push( @$results, {
	    channel => $$args{channel},
	    body => sprintf('%s played: [%d,%d]',
			    $$args{who}, $$play[1][0], $$play[1][1])
	});
    }

    #   Process play
    if ( !$table->processPlay( $player, $play ) ) {
	return undef;
    }

    return $results;

}

sub showPlayersDominos {
    my $self = shift;
    my $table = $$self{table};
    my $str = '';
    foreach my $player (@{$$table{players}}) {
	$str .= sprintf( "Player %d (t:%d) (p:%02d): %s\n", $$player{id}, $$player{team}, $player->handPoints, $self->dominosStr($$player{dominos}) );
    }

    return $str;
}

sub showStatus {
    my ($self, $args, $player) = @_;
    my $table = $$self{table};
    return [{
	channel => $$args{channel},
	body    => $self->showTableDominos
    },{
	who     => $$player{name},
	channel => 'msg',
	body    => $self->playerDominosStr( $$player{dominos} )
    },{
	channel => $$args{channel},
	body    => sprintf( '%s turn', $$table{players}[$$table{current_player}]{name} )
    }];
}

sub showTableDominos {
    my $self = shift;
    my $table = $$self{table};
    my $dominos = $$table{dominos};
    my $str = sprintf "< %s >\n", $self->dominosStr($dominos);
    foreach my $team (@{$$table{teams}}) {
	$str .= sprintf( "Team %d: %03d ", $$team{id}, $$team{points} );
    }
    return $str;
}

sub sitPlayer {
    my ($self, $player_type, $name, $args) = @_;
    my $table = $$self{table};
    my $players_count = $table->getPlayersCount;
    my $player = $table->sitPlayer( $player_type,
				    {
					team => $players_count % 2,
					name => $name
				    });
    $$table{players_map}{$name} = $player;
    my $results = [
	{
	    channel => $$args{channel},
	    body    => sprintf('%s joined the game for team %d!', $name, $$player{team})
	}];

    return $results;
}

sub playerDominosStr {
    my ($self, $dominos) = @_;
    my $str_dominos = '';
    my $i = 1;
    foreach my $domino (@$dominos) {
	$str_dominos .= sprintf "%d:[%d,%d] ", $i++, $$domino[0], $$domino[1];
    }
    return $str_dominos;
}

sub run {
    my ($self, $args, $command) = @_;
    my $table = $$self{table};

    # Get player input
    my $results = $self->gameStep($table, $args, $command);
    if (!$results) {
	return [{
	    who     => $$args{who},
	    channel => 'msg',
	    body    => 'Invalid domino'
	}];
    }

    # Get Status
    my $status = $self->getGameStatus;

    # Set new data
    my $new_player;
    if ($$status{new_round}) {
	$$table{round}++;
	$self->prepareNewRound;
	$new_player = $$table{players}[$$table{current_player}];
	push( @$results, {
	    channel => $$args{channel},
	    body => sprintf( "Winner: %s By: %s\n", $$new_player{name}, $$status{win_type} )
	});
    }
    elsif (!$$status{ended}) {
	my $valid = $table->validValues;
	my $can_play;
	do {
	    $table->setCurrentPlayer( defined $$status{winner}
				      ? $$status{winner}
				      : $table->getNextId
	    );
	    $new_player = $$table{players}[$$table{current_player}];
	    $can_play = $new_player->canPlay($valid);
	    if (!$can_play) {
		push( @$results, {
		    channel => $$args{channel},
		    body    => sprintf( '%s passed', $$new_player{name} )
		});
	    }
	} while($valid && !$can_play);
    }


    if ($$status{ended}) {
	$new_player = $$table{players}[$$status{winner}];
	push( @$results, {
	    channel => $$args{channel},
	    body    => sprintf( "Game Ended! Winner: %s, By: %s, Team: %s | Team 0: %d, Team 1: %d\n",
				$$new_player{name},
				$$status{win_type},
				$$new_player{team},
				$$table{teams}[0]{points},
				$$table{teams}[1]{points}
		)
	});
	delete $$self{table};
    }
    else {
	push( @$results, @{$self->showStatus($args, $new_player)} );
    }

    return $results;
}

1;
