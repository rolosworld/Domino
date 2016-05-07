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
package Domino::Player::Bot;
use Modern::Perl;
use parent 'Domino::Player';

sub getPlay {
    my ($self, $table) = @_;
    for my $domino (@{$$self{dominos}}) {
	if ( $table->validDomino($domino) ) {
	    my $valid = $table->validValues;
	    my $val = $$domino[0];
	    if ($valid && $$valid[0] != $val && $$valid[1] != $val) {
		$val = $$domino[1];
	    }

	    return [$val, $domino];
	}
    }

    return undef;
}

1;
