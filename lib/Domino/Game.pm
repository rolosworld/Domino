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
package Domino::Game;
use Modern::Perl;

use Domino::Table;

sub new {
    my ($class, $args) = @_;
    bless $args, $class;
    my $self = $args;

    $$self{table} = Domino::Table->new({%$args});
    return $self;
}

sub dominosStr {
    my ($self, $dominos) = @_;
    my $str_dominos = '';
    foreach my $domino (@$dominos) {
	$str_dominos .= sprintf "[%d,%d]", $$domino[0], $$domino[1];
    }
    return $str_dominos;
}

sub getGameStatus {
    my ($self) = @_;
    my $table = $$self{table};
    my $status = {
	new_round => 0,
	ended => 1,
    };
    my $valid = $table->validValues;
    return $status if !$valid;

    my $player = $$table{players}[$$table{current_player}];
    if (scalar @{$$player{dominos}} == 0) {
	$$status{winner} = $$table{current_player};
	$$status{win_type} = 'no_dominos';
    }
    else {
	foreach $player (@{$$table{players}}) {
	    if ($player->canPlay($valid)) {
		$$status{ended} = 0;
		last;
	    }
	}

	if ($$status{ended}) {
	    $$status{winner} = $table->leastHandPoints; # TODO: Trancado + Empate?
	    $$status{win_type} = 'least_points';
	}
    }

    if ($$status{ended}) {
	my $player = $$table{players}[$$status{winner}];
	my $team_id = $$player{team};
	my $team = $$table{teams}[$team_id];
	$$team{points} += $table->totalPlayerPoints;

	if ($$team{points} < $$table{game_points_limit}) {
	    $$status{new_round} = 1;
	    $$status{ended} = 0;
	}
    }

    return $status;
}

sub setTable {
    my ($self, $table) = @_;
    $$self{table} = $table;
}

sub prepareNewRound {
    my $self = shift;
    my $table = $$self{table};
    $table->genDominos;
    $table->shuffle;
    $table->giveDominos;
}

1;
