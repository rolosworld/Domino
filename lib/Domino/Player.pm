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
package Domino::Player;
use Modern::Perl;

sub new {
    my ($class, $args) = @_;
    return bless $args || {}, $class;
}

sub deleteDomino {
    my ($self, $_domino) = @_;
    for ( my $i = 0; $i < scalar @{$$self{dominos}}; $i++ ) {
	my $domino = $$self{dominos}[$i];
	if ( $$_domino[0] == $$domino[0] && $$_domino[1] == $$domino[1] ||
	     $$_domino[0] == $$domino[1] && $$_domino[1] == $$domino[0]
	    ) {
	    splice @{$$self{dominos}}, $i, 1;
	    return;
	}
    }
}

sub canPlay {
    my ($self, $values) = @_;
    if ( !$values ) {
	return 1;
    }

    foreach my $domino (@{$$self{dominos}}) {
	if ( $$domino[0] == $$values[0] ||
	     $$domino[0] == $$values[1] ||
	     $$domino[1] == $$values[0] ||
	     $$domino[1] == $$values[1]
	    ) {
	    return 1;
	}
    }

    return 0;
}

sub handPoints {
    my $self = shift;
    my $dominos = $$self{dominos};

    my $domino_points = 0;
    for ( my $i = 0; $i < scalar @$dominos; $i++ ) {
	my $domino = $$dominos[$i];
	$domino_points += $$domino[0] + $$domino[1];
    }
    return $domino_points;
}

sub hasDomino {
    my ($self, $domino) = @_;
    for ( my $i = 0; $i < scalar @{$$self{dominos}}; $i++ ) {
	my $_domino = $$self{dominos}[$i];
	if ( $$domino[0] == $$_domino[0] && $$domino[1] == $$_domino[1] ||
	     $$domino[1] == $$_domino[0] && $$domino[0] == $$_domino[1]
	   ) {
	    return $i;
	}
    }

    return undef;
}

1;
