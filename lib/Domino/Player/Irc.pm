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
package Domino::Player::Irc;
use Modern::Perl;
use parent 'Domino::Player';

sub getPlay {
    my ($self, $table, $command) = @_;
    my $domino = $$command{domino};
    my $direction = $$command{direction};
    if ($domino > scalar @{$$self{dominos}}) {
	return undef;
    }
    $domino = $$self{dominos}[$domino];

    my $valid_value = $$domino[0];
    my $valid_values = $table->validValues;
    if ($valid_values) {
       $valid_value = $$valid_values[$direction];
    }

    my $play = [
	$valid_value,
	$domino
	];

    return $play;
}

1;
