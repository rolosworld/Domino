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
package Domino::Game::Irc::Commands::Status;
use Modern::Perl;

use parent 'Domino::Game::Irc::Commands';

sub run {
    my ($self, $ctx, $args) = @_;
    my $game = $$ctx{game};
    my $table = $$game{table};
    my $player = $$table{players_map}{$$args{who}};
    if ($player) {
	return $game->showStatus( $args, $player );
    }
    return undef;
}

1;
