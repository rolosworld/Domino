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
package Domino::Player::Terminal;
use Modern::Perl;
use parent 'Domino::Player';

sub dominosStr {
    my ($self, $dominos) = @_;
    my $str_dominos = '';
    foreach my $domino (@$dominos) {
	$str_dominos .= sprintf "[%d,%d]", $$domino[0], $$domino[1];
    }
    return $str_dominos;
}

sub getPlay {
    my ($self, $table) = @_;
    my $play;

    my $valid_values = $table->validValues;
    if ( !$self->canPlay($valid_values) ) {
	return $play;
    }


    my $domino_str = $self->dominosStr($$self{dominos});
    my $numbers_str = '';
    for (my $i = 1; $i < scalar( @{$$self{dominos}} ) + 1; $i++) {
	$numbers_str .= sprintf( '%'.($i == 1? 3 : 5).'s', $i );
    }

    my $valid;
    while (!$valid) {
	printf "%s\n", $numbers_str;
	printf '%s (<# or >#): ', $domino_str;
	my $domino_move = <STDIN>;
	next if !$domino_move;

	my $direction = substr( $domino_move, 0, 1 );
	next if $direction ne '>' && $direction ne '<';
	$direction = $direction eq '<' ? 0 : 1;

	my $domino = substr( $domino_move, 1 ) - 1;
	next if $domino < 0 || $domino > scalar @{$$self{dominos}};
	$domino = $$self{dominos}[$domino];

	my $valid_value = $$domino[0];
	if ($valid_values) {
	    $valid_value = $$valid_values[$direction];
	    next if $$domino[0] != $valid_value && $$domino[1] != $valid_value;
	}

	$play = [
	    $valid_value,
	    $domino
	    ];

	$valid = 1;
    }

    return $play;
}

1;
