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
package Domino::Table;
use Modern::Perl;

use List::Util;
use Domino::Player::Terminal;
use Domino::Player::Bot;
use Domino::Player::Irc;
use Domino::Team;

sub new {
    my ($class, $args) = @_;
    $$args{round} = 0;
    $$args{players} = [];
    return bless $args, $class;
}

sub addDomino {
    my ($self, $value, $domino) = @_;
    my $valid = $self->validValues;
    if ( $valid ) {
	if ( $value == $$valid[0] ) {
	    if ($value == $$domino[0]) {
		$domino = $self->flipDomino($domino);
	    }
	    $$self{dominos} = [
		$domino,
		@{$$self{dominos}}
		];
	}
	else {
	    if ($value == $$domino[1]) {
		$domino = $self->flipDomino($domino);
	    }
	    $$self{dominos} = [
		@{$$self{dominos}},
		$domino
		];
	}
    }
    else {
	$$self{dominos} = [$domino];
    }
}

sub flipDomino {
    my ($self, $domino) = @_;
    return [$$domino[1], $$domino[0]];
}

sub getCurrentPlayer {
    my ($self) = @_;
    if ( !defined $$self{current_player} ) {
	for ( my $i = 0; $i < $$self{num_players}; $i++ ) {
	    my $player = $$self{players}[$i];
	    my @dominos = @{$$player{dominos}};
	    foreach my $domino (@dominos) {
		if ( $$domino[0] == $$domino[1] && $$domino[0] == $$self{max_domino_value} ) {
		    $self->setCurrentPlayer($i);
		    return $$self{current_player};
		}
	    }
	}
    }

    return $$self{current_player};
}

sub genDominos {
    my $self = shift;
    my $max = $$self{max_domino_value};
    my @dominos;

    for ( my $i = 0; $i <= $max; $i++ ) {
	for ( my $j = $i; $j <= $max; $j++ ) {
	    push( @dominos, [$i, $j] );
	}
    }

    $$self{dominos} = \@dominos;
}

sub getNextId {
    my ($self, $id) = @_;
    if ( !defined $id ) {
	$id = $$self{current_player};
    }
    $id++;
    $id = 0 if $id + 1 > $$self{num_players};
    return $id;
}

sub getPlayersCount {
    my $self = shift;
    return scalar @{$$self{players}};
}

sub giveDominos {
    my $self = shift;
    my @dominos = @{$$self{dominos}};
    my $num_tiles = scalar(@dominos) / $$self{num_players};

    for ( my $i = 0; $i < $$self{num_players}; $i++) {
	my @player_dominos = splice @dominos, 0, $num_tiles;
	$$self{players}[$i]{dominos} = \@player_dominos;
    }

    $$self{dominos} = \@dominos;
}

sub leastHandPoints {
    my $self = shift;
    my $pid = 0;
    my $points = -1;
    for ( my $i = 0; $i < $$self{num_players}; $i++) {
	my $_points = $$self{players}[$i]->handPoints;
	if ( $_points < $points || $points < 0 ) {
	    $points = $_points;
	    $pid = $i;
	}
    }
    return $pid;
}

sub prepare {
    my $self = shift;
    my $tile_count = 0;
    my $num_players = $$self{num_players};

    my $team = 0;

    for ( my $i = 0; $i < $num_players; $i++ ) {
	my $player_type = $$self{player_types}[$i];
	$self->sitPlayer( $player_type, { team => $team } );

	if ($$self{noteams}) {
	    $team++;
	} else {
	    $team = $team ? 0 : 1; # TODO: mas de 2 teams?
	}
    }
}

sub processPlay {
    my ( $self, $player, $play ) = @_;
    if ( $play ) {
	if ( !$self->validDomino($$play[1], $$play[0]) ) {
	    return 0;
	}

	$player->deleteDomino($$play[1]);
	$self->addDomino(@$play);
    }
    return 1;
}

sub setCurrentPlayer {
    my ($self, $player) = @_;
    $$self{current_player} = $player;
}

sub setNextPlayer {
    my ($self) = @_;
    $self->setCurrentPlayer( $self->getNextId );
}

sub shuffle {
    my $self = shift;
    my @dominos = @{$$self{dominos}};
    @dominos = List::Util::shuffle @dominos;
    $$self{dominos} = \@dominos;
}

sub sitPlayer {
    my ($self, $player_type, $args) = @_;
    my $player_class = 'Domino::Player::' . $player_type;
    my $team = $$args{team};
    my $players = $$self{players};

    my $player = $player_class->new(
	{
	    id => scalar(@$players),
	    %$args,
	});


    if ( !$$self{teams} ) {
	$$self{teams} = [];
    }

    if ( !$$self{teams}[$team] ) {
	my $teams = Domino::Team->new(
	    {
		id => $team,
		points => 0
	    });
	push (@{$$self{teams}}, $teams);
    }
    
    push(@{$$self{players}}, $player);
    return $player;
}

sub totalPlayerPoints {
    my $self = shift;
    my $total_points = 0;
    foreach my $player (@{$$self{players}}) {
	$total_points += $player->handPoints;
    }
    return $total_points;
}

sub validDomino {
    my ($self, $domino, $value) = @_;
    my $valid = $self->validValues;
    if ($valid) {
	if (defined $value) {
	    if ( $value != $$valid[0] && $value != $$valid[1] ) {
		return 0;
	    }

	    if ( $value != $$domino[0] && $value != $$domino[1] ) {
		return 0;
	    }
	}

	if ( $$domino[0] == $$valid[0] ||
	     $$domino[0] == $$valid[1] ||
	     $$domino[1] == $$valid[0] ||
	     $$domino[1] == $$valid[1]
	    ) {
	    return 1;
	}
    }
    else {
	if ($$self{round} != 0) {
	    return 1;
	}

	if ( $$domino[0] == $$domino[1] && $$domino[0] == $$self{max_domino_value} ) {
	    return 1;
	}
    }

    return 0;
}

sub validValues {
    my ($self) = @_;
    return [$$self{dominos}[0][0],$$self{dominos}[-1][1]] if @{$$self{dominos}};
}

1;
