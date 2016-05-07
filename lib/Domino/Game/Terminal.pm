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
package Domino::Game::Terminal;
use Modern::Perl;

use parent 'Domino::Game';

sub gameStep {
    my ($self, $table) = @_;
    my $current = $table->getCurrentPlayer;
    my $player = $$table{players}[$current];
    my $play = $player->getPlay( $table );
    if ($play) {
	printf "Player %d played [%d,%d]\n", $current, $$play[1][0], $$play[1][1];
    }
    else {
	printf "Player %d passed\n", $current;
    }
    $table->processPlay( $player, $play );
}

sub showPlayersDominos {
    my $self = shift;
    my $table = $$self{table};
    printf "%21s", '';
    for (my $i = 1; $i < $$table{max_domino_value} + 2; $i++) {
	printf "%5s", $i;
    }
    print "\n";
    foreach my $player (@{$$table{players}}) {
	printf "Player %d (t:%d) (p:%02d): %s\n", $$player{id}, $$player{team}, $player->handPoints, $self->dominosStr($$player{dominos});
    }
}

sub showTableDominos {
    my $self = shift;
    my $table = $$self{table};
    my $dominos = $$table{dominos};

    printf "< %s >\n", $self->dominosStr($dominos);
    #printf "Total Points: %d\n", $table->totalPlayerPoints;
    print "Team Points:\n";
    foreach my $team (@{$$table{teams}}) {
	printf "Team %d: %03d\t", $$team{id}, $$team{points};
    }
    print "\n";
}

sub run {
    my ($self, $args) = @_;
    my $table = $$self{table};
    $table->prepare;

    my $status = {};
    $self->prepareNewRound;
    while (!$$status{ended}) {
	# Draw results
	$self->showTableDominos;
	$self->showPlayersDominos;
	printf "%s\n", '=' x 80;

	# Get player input
	$self->gameStep($table);
	printf "%s\n", '=' x 80;

	# Get Status
	$status = $self->getGameStatus;

	# Set new data
	if ($$status{new_round}) {
	    printf "%s\n", '#' x 80;
	    printf "Winner: %d By: %s\n", $$status{winner}, $$status{win_type};
	    printf "%s\n", '#' x 80;
	    $$table{round}++;
	    $self->prepareNewRound
	}
	else {
	    $table->setCurrentPlayer( defined $$status{winner}
				      ? $$status{winner}
				      : $table->getNextId
		);
	}

    };
    $self->showTableDominos;
    $self->showPlayersDominos;
}

1;
